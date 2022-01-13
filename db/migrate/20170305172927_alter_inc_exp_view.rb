class AlterIncExpView < ActiveRecord::Migration[5.2]
  def up
    sql = %q(
          DROP VIEW IF EXISTS inc_exp_view;
          DROP VIEW IF EXISTS exp_view;
          DROP VIEW IF EXISTS inc_view;
          DROP VIEW IF EXISTS exp_com_view;
          DROP VIEW IF EXISTS exp_fee_view;
          DROP VIEW IF EXISTS inc_pnl_view;
          )
    execute(sql)
    sql = %q(
          DROP VIEW IF EXISTS inc_view;
          CREATE VIEW
              inc_view AS
          SELECT
              posted_on,
              account_code,
              claim_set_code,
              SUM(done)                   AS done,
              SUM(pnl_usd)::DECIMAL(16,2) AS inc_usd
          FROM
              (
               SELECT
                      n.posted_on AS posted_on,
                      a.code      AS account_code,
                      s.code      AS claim_set_code,
                      done        AS done,
                      CASE
                          WHEN x.code IN ('EUR',
                                          'GBP',
                                          'AUD',
                                          'NZD')
                          THEN pnl * m.mark
                          ELSE pnl/m.mark
                      END AS pnl_usd
                 FROM
                      claims c,
                      claim_sets s,
                      accounts a,
                      currencies x,
                      currency_marks m,
                      position_nettings n
                WHERE
                      c.id = n.claim_id AND
                      a.id = n.account_id AND
                      x.id = c.point_currency_id AND
                      s.id = c.claim_set_id AND
                      x.id = m.currency_id AND
                      n.posted_on = m.posted_on )x
          GROUP BY
              posted_on,
              account_code,
              claim_set_code
          )
    execute(sql)
    sql = %q(
          CREATE VIEW
              exp_view AS
          SELECT
              posted_on,
              account_code,
              claim_set_code,
              SUM(exp_usd)::DECIMAL(16,2) AS exp_usd
          FROM
              (
               SELECT
                      c.posted_on AS posted_on,
                      a.code      AS account_code,
                      s.code      AS claim_set_code,
                      c.amount,
                      x.code,
                      CASE
                          WHEN x.code IN ('EUR',
                                          'GBP',
                                          'AUD',
                                          'NZD')
                          THEN c.amount * m.mark
                          ELSE c.amount/m.mark
                      END AS exp_usd
                 FROM
                      accounts a,
                      charges c,
                      chargeables b,
                      claim_sets s,
                      currencies x,
                      currency_marks m
                WHERE
                      a.id = c.account_id AND
                      b.id = c.chargeable_id AND
                      s.id = b.claim_set_id AND
                      x.id = c.currency_id AND
                      x.id = m.currency_id AND
                      c.posted_on = m.posted_on)x
          GROUP BY
              posted_on,
              account_code,
              claim_set_code
          )
    execute(sql)
    sql = %q(
          CREATE VIEW
              inc_exp_view AS
          SELECT
              i.posted_on,
              i.account_code,
              i.claim_set_code,
              i.done,
              i.inc_usd             AS inc,
              e.exp_usd             AS exp,
              i.inc_usd + e.exp_usd AS net
          FROM
              inc_view i,
              exp_view e
          WHERE
              i.posted_on = e.posted_on AND
              i.account_code = e.account_code AND
              i.claim_set_code = e.claim_set_code
          ORDER BY
              posted_on,
              account_code,
              claim_set_code
          )
    execute(sql)
  end

  def down
    raise  ActiveRecord::IrreversibleMigration
  end
end
