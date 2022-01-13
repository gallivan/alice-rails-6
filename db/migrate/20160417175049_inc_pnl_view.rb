class IncPnlView < ActiveRecord::Migration[5.2]
  def up
    sql = %q(
          DROP VIEW IF EXISTS inc_pnl_view;
          CREATE VIEW
              inc_pnl_view AS
          SELECT
              a.code as "account_code",
              n.posted_on,
              s.code as "claim_set_code",
              done,
              pnl as amount,
              x.code as currency_code
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
              s.id = c.claim_set_id
          )
    execute(sql)
  end

  def down
    execute('drop view if exists inc_pnl_view')
  end
end
