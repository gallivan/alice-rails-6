class CreateAdjustmentTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :adjustment_types do |t|
      t.string :code
      t.string :name

      t.timestamps null: false
    end
    add_index :adjustment_types, :code, unique: true, name: 'adjustment_type_code_uq'
    add_index :adjustment_types, :name, unique: true, name: 'adjustment_type_name_uq'
  end
end
