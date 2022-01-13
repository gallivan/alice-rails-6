class CreateFeeChargeableTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :fee_chargeable_types do |t|
      t.string :code
      t.string :name

      t.timestamps null: false
    end
    add_index :fee_chargeable_types, :code, unique: true, name: 'fee_chargeable_type_code_uq'
    add_index :fee_chargeable_types, :name, unique: true, name: 'fee_chargeable_type_name_uq'
  end
end
