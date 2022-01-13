class CreateLedgerBalanceByCurrencyAndPostedOnViewProxies < ActiveRecord::Migration[5.2]
  def up
    sql = %q(
            DROP VIEW IF EXISTS ledger_balance_by_currency_and_posted_on_view;
            CREATE VIEW
                ledger_balance_by_currency_and_posted_on_view AS
            SELECT
                c.id as currency_id,
                m.posted_on,
                SUM(ROUND(m.ledger_balance, 2)) AS ledger_balance,
                kind
            FROM
                currencies c,
                money_lines m
            WHERE
                m.kind = 'HELD' AND
                c.id = m.currency_id
            GROUP BY
                c.id,
                kind,
                m.posted_on
              ORDER BY
                m.posted_on DESC,
                c.code
            )
    execute(sql)
  end

  def down
    execute('drop view if exists ledger_balance_by_currency_and_posted_on_view')
  end
end
