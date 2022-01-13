class CreatePackerReports < ActiveRecord::Migration[5.2]
  def change
    create_table :packer_reports do |t|
      t.date :posted_on, null: false
      t.string :kind, null: false
      t.string :fate, null: false
      t.text :data, null: false
      t.text :goof_error
      t.text :goof_trace

      t.timestamps null: false
    end
    add_index :packer_reports, :kind
    add_index :packer_reports, :fate
    add_index :packer_reports, :posted_on
  end
end
