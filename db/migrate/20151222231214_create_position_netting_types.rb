class CreatePositionNettingTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :position_netting_types do |t|
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :position_netting_types, :code, unique: true, name: 'position_netting_type_code_uq'
    add_index :position_netting_types, :name, unique: true, name: 'position_netting_type_name_uq'
  end
end
