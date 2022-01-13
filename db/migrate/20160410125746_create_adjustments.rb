class CreateAdjustments < ActiveRecord::Migration[5.2]
  def change
    create_table :adjustments do |t|
      t.integer :account_id
      t.integer :adjustment_type_id
      t.integer :journal_entry_id
      t.decimal :amount
      t.integer :currency_id
      t.date :posted_on
      t.string :memo

      t.timestamps null: false
    end
    add_foreign_key :adjustments, :accounts, name: 'adjustment_account_fk'
    add_foreign_key :adjustments, :adjustment_types, name: 'adjustment_adjustment_type_fk'
    add_foreign_key :adjustments, :journal_entries, name: 'adjustment_journal_entry_fk'
  end
end
