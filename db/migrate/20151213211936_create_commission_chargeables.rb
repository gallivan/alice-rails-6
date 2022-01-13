class CreateCommissionChargeables < ActiveRecord::Migration[5.2]
  def change
    create_table :commission_chargeables do |t|
      t.integer :commission_chargeable_type_id, null: false
      t.integer :claim_set_id
      t.integer :currency_id, null: false
      t.decimal :amount, null: false
      t.date :begun_on, null: false
      t.date :ended_on

      t.timestamps null: false
    end
    add_foreign_key :commission_chargeables, :commission_chargeable_types, name: 'commission_chargeable_commission_type_fk'
    add_foreign_key :commission_chargeables, :claim_sets, name: 'commission_chargeable_claim_set_fk'
    add_foreign_key :commission_chargeables, :currencies, name: 'commission_chargeable_currency_fk'
  end
end