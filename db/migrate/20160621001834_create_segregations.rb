class CreateSegregations < ActiveRecord::Migration[5.2]
  def up
    create_table :segregations do |t|
      t.string :code
      t.string :name
      t.string :note

      t.timestamps null: false
    end

    add_column :fees, :segregation_id, :integer, null: false
    add_foreign_key :fees, :segregations

    add_column :commissions, :segregation_id, :integer, null: false
    add_foreign_key :commissions, :segregations

    add_column :adjustments, :segregation_id, :integer, null: false
    add_foreign_key :adjustments, :segregations

    add_column :journal_entries, :segregation_id, :integer, null: false
    add_foreign_key :journal_entries, :segregations

    remove_index :ledger_entries, name: :ledger_entries_uq
    add_column :ledger_entries, :segregation_id, :integer, null: false
    add_foreign_key :ledger_entries, :segregations
    add_index :ledger_entries, [:posted_on, :account_id, :ledger_id, :ledger_entry_type_id, :currency_id, :segregation_id], unique: true, name: :ledger_entries_uq

    add_column :money_lines, :segregation_id, :integer, null: false
    add_foreign_key :money_lines, :segregations

    remove_index :money_lines, name: :money_lines_uq
    add_index :money_lines, [:account_id, :currency_id, :segregation_id, :posted_on, :kind], unique: true, name: :money_lines_uq

    remove_index :statement_money_lines, name: :statement_money_line_uq # note spelling error: line vs lines
    add_column :statement_money_lines, :segregation_code, :string, null: false
    add_index :statement_money_lines, [:account_id, :stated_on, :currency_code, :kind, :segregation_code], unique: true, name: :statement_money_lines_uq

  end

  def down
    remove_foreign_key :fees, :segregations
    remove_column :fees, :segregation_id

    remove_foreign_key :commissions, :segregations
    remove_column :commissions, :segregation_id

    remove_foreign_key :adjustments, :segregations
    remove_column :adjustments, :segregation_id

    remove_foreign_key :journal_entries, :segregations
    remove_column :journal_entries, :segregation_id

    remove_foreign_key :ledger_entries, :segregations
    remove_column :ledger_entries, :segregation_id

    remove_index :money_lines, name: :money_lines_uq
    remove_foreign_key :money_lines, :segregations
    remove_column :money_lines, :segregation_id
    add_index :money_lines, [:account_id, :currency_id, :posted_on, :kind], unique: true, name: :money_lines_uq

    remove_index :statement_money_lines, name: :statement_money_lines_uq
    remove_column :statement_money_lines, :segregation_code
    add_index :statement_money_lines, [:account_id, :stated_on, :currency_code, :kind], unique: true, name: :statement_money_lines_uq

    drop_table :segregations
  end

end
