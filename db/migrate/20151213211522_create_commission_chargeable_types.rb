class CreateCommissionChargeableTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :commission_chargeable_types do |t|
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :commission_chargeable_types, :code, unique: true, name: 'commission_chargeable_type_code_uq'
    add_index :commission_chargeable_types, :name, unique: true, name: 'commission_chargeable_type_name_uq'
  end
end
