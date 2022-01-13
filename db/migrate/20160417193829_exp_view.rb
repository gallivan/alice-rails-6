class ExpView < ActiveRecord::Migration[5.2]
  def up
    sql = %q(
          DROP VIEW IF EXISTS exp_view;
          CREATE VIEW
              exp_view AS
          SELECT
              account_code,
              posted_on,
              claim_set_code,
              SUM(amount) AS amount
          FROM
              (
               SELECT
                      v.account_code,
                      v.posted_on,
                      v.claim_set_code,
                      v.amount * m.mark AS amount
                 FROM
                      exp_fee_view v,
                      currencies x,
                      currency_marks m
                WHERE
                      x.id = m.currency_id AND
                      x.code = v.currency_code AND
                      m.posted_on = v.posted_on
                UNION
               SELECT
                      v.account_code,
                      v.posted_on,
                      v.claim_set_code,
                      v.amount * m.mark AS amount
                 FROM
                      exp_com_view v,
                      currencies x,
                      currency_marks m
                WHERE
                      x.id = m.currency_id AND
                      x.code = v.currency_code AND
                      m.posted_on = v.posted_on )x
          GROUP BY
              posted_on,
              account_code,
              claim_set_code
          )
    execute(sql)
  end

  def down
    execute('drop view if exists exp_view')
  end
end
