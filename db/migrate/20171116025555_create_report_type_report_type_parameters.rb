class CreateReportTypeReportTypeParameters < ActiveRecord::Migration[5.2]
  def change
    create_table :report_type_report_type_parameters do |t|
      t.integer :report_type_id, null: false
      t.integer :report_type_parameter_id, null: false

      t.timestamps null: false
    end
    add_foreign_key :report_type_report_type_parameters, :report_types, name: :report_type_report_type_parameters_fk_01
    add_foreign_key :report_type_report_type_parameters, :report_type_parameters, name: :report_type_report_type_parameters_fk_02
  end
end
