class CreateReportTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :report_types do |t|
      t.string :code
      t.string :name

      t.timestamps null: false
    end
    add_index :report_types, :code, unique: true, name: :report_type_code_uq
    add_index :report_types, :name, unique: true, name: :report_type_name_uq
  end
end
