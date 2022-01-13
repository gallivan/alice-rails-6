class CreateFillChargeJournalEntries < ActiveRecord::Migration[5.2]
  def change
    create_table :fill_charge_journal_entries do |t|
      t.integer :deal_leg_fill_id
      t.integer :charge_id
      t.integer :journal_entry_id

      t.timestamps null: false
    end
    add_foreign_key :fill_charge_journal_entries, :charges,         name: :fill_charge_journal_entries_charges_fk
    add_foreign_key :fill_charge_journal_entries, :deal_leg_fills,  name: :fill_charge_journal_entries_fills_fk
    add_foreign_key :fill_charge_journal_entries, :journal_entries, name: :fill_charge_journal_entries_journal_entries_fk
  end
end
