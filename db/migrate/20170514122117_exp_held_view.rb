class ExpHeldView < ActiveRecord::Migration[5.2]
  def up
    sql = %q(
          DROP VIEW IF EXISTS exp_held_view;
          CREATE VIEW
              exp_held_view AS
          SELECT
              posted_on,
              account_code,
              claim_set_code,
              SUM(exp)::DECIMAL(16,2),
              currency_code
          FROM
              (
               SELECT
                      c.posted_on AS posted_on,
                      a.code      AS account_code,
                      s.code      AS claim_set_code,
                      c.amount,
                      x.code,
                      c.amount AS exp,
                      x.code   AS currency_code
                 FROM
                      accounts a,
                      charges c,
                      chargeables b,
                      claim_sets s,
                      currencies x
                WHERE
                      a.id = c.account_id AND
                      b.id = c.chargeable_id AND
                      s.id = b.claim_set_id AND
                      x.id = c.currency_id)x
          GROUP BY
              posted_on,
              account_code,
              claim_set_code,
              currency_code
          )
    execute(sql)
  end

  def down
    sql = 'DROP VIEW IF EXISTS exp_held_view;'
    execute(sql)
  end
end
