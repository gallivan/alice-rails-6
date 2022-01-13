class CreateFeeChargeables < ActiveRecord::Migration[5.2]
  def change
    create_table :fee_chargeables do |t|
      t.integer :fee_chargeable_type_id, null: false
      t.integer :claim_set_id
      t.integer :currency_id
      t.decimal :amount
      t.date :begun_on
      t.date :ended_on

      t.timestamps null: false
    end
    add_foreign_key :fee_chargeables, :fee_chargeable_types, name: 'fee_chargeable_type_fk'
    add_foreign_key :fee_chargeables, :claim_sets, name: 'fee_chargeable_claim_set_fk'
    add_foreign_key :fee_chargeables, :currencies, name: 'fee_chargeable_currency_fk'
  end
end
