class IncView < ActiveRecord::Migration[5.2]
  def up
    sql = %q(
          DROP VIEW IF EXISTS inc_view;
          CREATE VIEW
              inc_view AS
          SELECT
              account_code,
              claim_set_code,
              posted_on,
              SUM(done)   AS done,
              SUM(amount) AS amount
          FROM
              (
               SELECT
                      v.account_code,
                      v.posted_on,
                      v.claim_set_code,
                      v.done,
                      v.amount * m.mark AS amount,
                      'USD'             AS currency_code
                 FROM
                      inc_pnl_view v,
                      currencies x,
                      currency_marks m
                WHERE
                      x.id = m.currency_id AND
                      x.code = v.currency_code AND
                      m.posted_on = v.posted_on) x
          GROUP BY
              account_code,
              claim_set_code,
              posted_on
          )
    execute(sql)
  end

  def down
    execute('drop view if exists inc_view')
  end
end
