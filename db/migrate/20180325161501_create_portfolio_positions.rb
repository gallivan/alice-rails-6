class CreatePortfolioPositions < ActiveRecord::Migration[5.2]
  def change
    create_table :portfolio_positions do |t|
      t.references :portfolio, index: true, foreign_key: true, null: false
      t.references :position, index: true, foreign_key: true, null:false

      t.timestamps null: false
    end
  end
end
