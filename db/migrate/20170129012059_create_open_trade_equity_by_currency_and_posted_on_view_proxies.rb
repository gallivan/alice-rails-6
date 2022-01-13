class CreateOpenTradeEquityByCurrencyAndPostedOnViewProxies < ActiveRecord::Migration[5.2]
  def up
     sql = %q(
             DROP VIEW IF EXISTS open_trade_equity_by_currency_and_posted_on_view;
             CREATE VIEW
                 open_trade_equity_by_currency_and_posted_on_view AS
             SELECT
                 c.id as currency_id,
                 m.posted_on,
                 SUM(ROUND(m.open_trade_equity, 2)) AS open_trade_equity,
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
     execute('drop view if exists open_trade_equity_by_currency_and_posted_on_view')
   end
end
