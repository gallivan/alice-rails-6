class CreateCurrencies < ActiveRecord::Migration[5.2]
  def change
    create_table :currencies do |t|
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :currencies, :code, unique: true, name: 'currency_code_uq'
    add_index :currencies, :name, unique: true, name: 'currency_name_uq'
  end
end
