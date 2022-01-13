class IncExpView < ActiveRecord::Migration[5.2]
  def up
    sql = %q(
          DROP VIEW IF EXISTS inc_exp_view;
          CREATE VIEW
              inc_exp_view AS
          SELECT
              i.posted_on,
              i.account_code,
              i.claim_set_code,
              i.done,
              i.amount            AS inc,
              e.amount            AS exp,
              i.amount + e.amount AS net
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
    execute('drop view if exists inc_exp_view')
  end
end
