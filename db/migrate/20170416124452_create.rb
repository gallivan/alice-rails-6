class Create < ActiveRecord::Migration[5.2]
  def up
    sql = %q(
            DROP VIEW
            IF EXISTS claim_futures_view;
            CREATE VIEW
                claim_futures_view AS
            SELECT
                c.id as claim_id,
                claim_set_id,
                claim_type_id,
                entity_id,
                c.claimable_id,
                claimable_type,
                c.code,
                name,
                size,
                point_value,
                point_currency_id,
                expires_on,
                first_holding_on,
                first_intent_on,
                first_delivery_on,
                last_trade_on,
                last_intent_on,
                last_delivery_on
            FROM
                claims c,
                futures f
            WHERE
                f.id = c.claimable_id;
          )
    execute(sql)
  end

  def down
    sql = 'DROP VIEW IF EXISTS claim_futures_view;'
    execute(sql)
  end
end
