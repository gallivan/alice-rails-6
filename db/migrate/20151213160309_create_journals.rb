class CreateJournals < ActiveRecord::Migration[5.2]
  def change
    create_table :journals do |t|
      t.integer :journal_type_id, null: false
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :journals, :code, unique: true, name: 'journal_code_uq'
    add_index :journals, :name, unique: true, name: 'journal_name_uq'
    add_foreign_key :journals, :journal_types, name: 'journal_journal_type_fk'
  end
end
