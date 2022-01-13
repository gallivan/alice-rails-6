class CreateFuturesProfitAndLossByCurrencyAndPostedOnViewProxies < ActiveRecord::Migration[5.2]
  def up
     sql = %q(
             DROP VIEW IF EXISTS futures_profit_and_loss_by_currency_and_posted_on_view;
             CREATE VIEW
                 futures_profit_and_loss_by_currency_and_posted_on_view AS
             SELECT
                 c.id as currency_id,
                 m.posted_on,
                 SUM(ROUND(m.pnl_futures, 2)) AS pnl_futures,
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
     execute('drop view if exists futures_profit_and_loss_by_currency_and_posted_on_view')
   end
end
