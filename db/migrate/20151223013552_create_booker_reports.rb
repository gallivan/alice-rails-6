class CreateBookerReports < ActiveRecord::Migration[5.2]
  def change
    create_table :booker_reports do |t|
      t.date :posted_on
      t.string :kind, null: false
      t.string :fate, null: false
      t.text :data, null: false
      t.text :goof_error
      t.text :goof_trace

      t.timestamps null: false
    end
    add_index :booker_reports, :kind
    add_index :booker_reports, :fate
    add_index :booker_reports, :posted_on
  end
end
