class IncHeldView < ActiveRecord::Migration[5.2]
  def up
    sql = %q(
          DROP VIEW IF EXISTS inc_held_view;
          CREATE VIEW
              inc_held_view AS
          SELECT
                  posted_on,
                  account_code,
                  claim_set_code,
                  SUM(done)               AS done,
                  SUM(pnl)::DECIMAL(16,2) AS inc,
                  currency_code
              FROM
                  (
                   SELECT
                          n.posted_on AS posted_on,
                          a.code      AS account_code,
                          s.code      AS claim_set_code,
                          done        AS done,
                          pnl         AS pnl,
                          x.code      AS currency_code
                     FROM
                          claims c,
                          claim_sets s,
                          accounts a,
                          currencies x,
                          position_nettings n
                    WHERE
                          c.id = n.claim_id AND
                          a.id = n.account_id AND
                          x.id = c.point_currency_id AND
                          s.id = c.claim_set_id )x
              GROUP BY
                  posted_on,
                  account_code,
                  claim_set_code,
                  currency_code
          )
    execute(sql)
  end

  def down
    sql = 'DROP VIEW IF EXISTS inc_held_view;'
    execute(sql)
  end
end
