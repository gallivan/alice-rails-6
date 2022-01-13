class CreateCommissions < ActiveRecord::Migration[5.2]
  def change
    create_table :commissions do |t|
      t.integer :account_id, null: false
      t.integer :journal_entry_id
      t.decimal :amount, null: false
      t.integer :currency_id, null: false
      t.date :posted_on, null: false
      t.integer :commission_chargeable_id
      t.string :memo

      t.timestamps null: false
    end
    add_foreign_key :commissions, :accounts, name: 'commission_account_fk'
    add_foreign_key :commissions, :commission_chargeables, name: 'commission_fee_schedule_fk'
    add_foreign_key :commissions, :journal_entries, name: 'commission_journal_entry_fk'
  end
end
