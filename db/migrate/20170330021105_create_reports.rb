class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.belongs_to :report_type, index: true, foreign_key: true
      t.belongs_to :format_type, index: true, foreign_key: true
      t.string :memo
      t.string :location
      t.date :posted_on

      t.timestamps null: false
    end
    add_index :reports, [:report_type_id, :format_type_id, :posted_on], unique: true, name: :reports_uq
  end
end
