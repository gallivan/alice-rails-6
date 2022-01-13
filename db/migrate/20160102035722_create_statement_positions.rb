class CreateStatementPositions < ActiveRecord::Migration[5.2]
  def change
    create_table :statement_positions do |t|
      t.integer :account_id, null: false
      t.string :account_code, null: false
      t.string :claim_code, null: false
      t.string :claim_name, null: false
      t.date :stated_on, null: false
      t.date :posted_on, null: false
      t.date :traded_on, null: false
      t.decimal :bot, null: false
      t.decimal :sld, null: false
      t.decimal :net, null: false
      t.decimal :price, null: false
      t.decimal :mark, null: false
      t.decimal :ote, null: false
      t.string :currency_code, null: false
      t.string :position_status_code, null: false

      t.timestamps null: false
    end
    add_index :statement_positions, [:account_code, :claim_code, :posted_on, :traded_on, :price], name: 'statement_positions_uq'

    add_foreign_key :statement_positions, :accounts
  end
end
