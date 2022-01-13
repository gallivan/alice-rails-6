class CreateStatementPositionNettings < ActiveRecord::Migration[5.2]
  def change
    create_table :statement_position_nettings do |t|
      t.date :stated_on
      t.date :posted_on
      t.integer :account_id
      t.string :account_code
      t.string :claim_code
      t.string :claim_name
      t.string :netting_code
      t.decimal :bot_price_traded
      t.decimal :sld_price_traded
      t.decimal :done
      t.decimal :pnl
      t.string :currency_code

      t.timestamps null: false
    end
    add_index :statement_position_nettings, :posted_on
    add_index :statement_position_nettings, :claim_code
    add_index :statement_position_nettings, :account_code
    add_foreign_key :statement_position_nettings, :accounts, name: :statement_position_netting_account_fk
  end
end
