class CorrectMoneyLine < ActiveRecord::Migration[5.2]
  def up
    remove_index :money_lines, name: :money_lines_uq
    remove_foreign_key :money_lines, name: :money_line_ccy_held_fk
    remove_foreign_key :money_lines, name: :money_line_ccy_base_fk
    remove_foreign_key :money_lines, name: :money_line_currency_mark_fk

    add_column :money_lines, :kind, :string
    rename_column :money_lines, :currency_held_id, :currency_id
    remove_column :money_lines, :currency_base_id
    remove_column :money_lines, :currency_mark_id

    add_index :money_lines, [:account_id, :currency_id, :posted_on, :kind], unique: true, name: :money_lines_uq
    add_foreign_key :money_lines, :currencies, column: :currency_id, name: :money_line_ccy_base_fk

    execute <<-SQL
      update money_lines set kind = 'HELD';
    SQL
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
