class CreateMarginResponses < ActiveRecord::Migration[5.2]
  def change
    create_table :margin_responses do |t|
      t.references :margin_request, index: true, foreign_key: true
      t.references :margin_response_status, index: true, foreign_key: true
      t.string :body
      t.string :fail

      t.timestamps null: false
    end
  end
end
