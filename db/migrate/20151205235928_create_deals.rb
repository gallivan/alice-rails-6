class CreateDeals < ActiveRecord::Migration[5.2]
  def change
    create_table :deals do |t|
      t.integer :deal_type_id, null: false
      t.integer :account_id, null: false
      t.date :posted_on, null: false
      t.date :traded_on, null: false
      t.decimal :todo, null: false
      t.decimal :done
      t.decimal :todo_price, null: false
      t.decimal :done_price

      t.timestamps null: false
    end
    add_foreign_key :deals, :deal_types, name: 'deal_deal_type_fk'
    add_foreign_key :deals, :accounts, name: 'deal_account_fk'
  end
end
