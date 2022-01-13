class CreatePickerReports < ActiveRecord::Migration[5.2]
  def change
    create_table :picker_reports do |t|
      t.date :posted_on
      t.string :kind
      t.string :fate
      t.text :data
      t.text :goof_error
      t.text :goof_trace

      t.timestamps null: false
    end
    add_index :picker_reports, :kind
    add_index :picker_reports, :fate
    add_index :picker_reports, :posted_on
  end
end
