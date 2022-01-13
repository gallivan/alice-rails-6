class CreateMarginRequests < ActiveRecord::Migration[5.2]
  def change
    create_table :margin_requests do |t|
      t.references :margin, index: true, foreign_key: true
      t.references :margin_request_status, index: true, foreign_key: true
      t.string :body
      t.string :fail

      t.timestamps null: false
    end
  end
end
