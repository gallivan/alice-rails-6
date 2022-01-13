class CreateCharges < ActiveRecord::Migration[5.2]
  def change
    create_table :charges do |t|
      t.integer :account_id, null: false
      t.integer :chargeable_id, null: false
      t.integer :currency_id, null: false
      t.integer :segregation_id, null: false
      t.decimal :amount, null: false
      t.string :memo, null: false
      t.date :posted_on, null: false
      t.date :as_of_on, null: false
      t.integer :journal_entry_id

      t.timestamps null: false
    end
    add_foreign_key :charges, :accounts, name: :charges_accounts_fk
    add_foreign_key :charges, :chargeables, name: :charges_chargeables_fk
    add_foreign_key :charges, :currencies, name: :charges_currencies_fk
    add_foreign_key :charges, :segregations, name: :charges_segregations_fk
    add_foreign_key :charges, :journal_entries, name: :charges_journal_entries_fk
  end
end
