class CreateMargins < ActiveRecord::Migration[5.2]
  def change
    create_table :margins do |t|
      t.references :portfolio, index: true, foreign_key: true, null: false
      t.references :margin_calculator, index: true, foreign_key: true, null: false
      t.references :margin_status, index: true, foreign_key: true, null: false
      t.references :currency, index: true, foreign_key: true, null: false
      t.string :remote_portfolio_id
      t.string :remote_margin_id
      t.decimal :initial, precision: 12, scale: 2
      t.decimal :maintenance, precision: 12, scale: 2

      t.timestamps null: false
    end
  end
end
