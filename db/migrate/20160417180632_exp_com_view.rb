class ExpComView < ActiveRecord::Migration[5.2]
  def up
    sql = %q(
          DROP VIEW IF EXISTS exp_com_view;
          CREATE VIEW
              exp_com_view AS
          SELECT
              a.code as "account_code",
              f.posted_on,
              s.code as "claim_set_code",
              f.amount,
              x.code as currency_code
          FROM
              commissions f,
              accounts a,
              commission_chargeables c,
              claim_sets s,
              currencies x
          WHERE
              a.id = f.account_id AND
              c.id = f.commission_chargeable_id AND
              s.id = c.claim_set_id AND
              x.id = f.currency_id
          )
    execute(sql)
  end

  def down
    execute('drop view if exists exp_com_view')
  end
end
