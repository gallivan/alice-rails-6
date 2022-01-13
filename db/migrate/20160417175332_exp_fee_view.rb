class ExpFeeView < ActiveRecord::Migration[5.2]
  def up
    sql = %q(
          DROP VIEW IF EXISTS exp_fee_view;
          CREATE VIEW
              exp_fee_view AS
          SELECT
              a.code as "account_code",
              f.posted_on,
              s.code as "claim_set_code",
              f.amount,
              x.code as currency_code
          FROM
              fees f,
              accounts a,
              fee_chargeables c,
              claim_sets s,
              currencies x
          WHERE
              a.id = f.account_id AND
              c.id = f.fee_chargeable_id AND
              s.id = c.claim_set_id AND
              x.id = f.currency_id
          )
    execute(sql)
  end

  def down
    execute('drop view if exists exp_fee_view')
  end
end
