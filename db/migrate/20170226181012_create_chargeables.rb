class CreateChargeables < ActiveRecord::Migration[5.2]
  def change
    create_table :chargeables do |t|
      t.integer :chargeable_type_id, null: false
      t.integer :claim_set_id, null: false
      t.integer :currency_id, null: false
      t.decimal :amount, null: false
      t.date :begun_on, null: false
      t.date :ended_on, null: false

      t.timestamps null: false
    end
    add_index :chargeables, [:chargeable_type_id, :claim_set_id], unique: true, name: 'chargeables_uq'
  end
end
