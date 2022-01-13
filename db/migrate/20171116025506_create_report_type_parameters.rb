class CreateReportTypeParameters < ActiveRecord::Migration[5.2]
  def change
    create_table :report_type_parameters do |t|
      t.string :handle, null: false
      t.string :bucket, null: false

      t.timestamps null: false
    end
  end
end
