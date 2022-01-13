class CreateJournalTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :journal_types do |t|
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :journal_types, :code, unique: true, name: 'journal_type_code_uq'
    add_index :journal_types, :name, unique: true, name: 'journal_type_name_uq'
  end
end
