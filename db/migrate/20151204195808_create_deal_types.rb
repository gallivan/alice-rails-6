class CreateDealTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :deal_types do |t|
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :deal_types, :code, unique: true, name: 'deal_type_code_uq'
    add_index :deal_types, :name, unique: true, name: 'deal_type_name_uq'
  end
end
