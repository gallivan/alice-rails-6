class CreateChargeableTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :chargeable_types do |t|
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :chargeable_types, :code, unique: true, name: 'chargeable_types_code_uq'
    add_index :chargeable_types, :name, unique: true, name: 'chargeable_types_name_uq'
  end
end
