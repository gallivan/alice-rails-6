class CreateFormatTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :format_types do |t|
      t.string :code
      t.string :name

      t.timestamps null: false
    end
    add_index :format_types, :code, unique: true, name: :format_type_code_uq
    add_index :format_types, :name, unique: true, name: :format_type_name_uq
  end
end
