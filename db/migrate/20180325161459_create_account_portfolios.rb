class CreateAccountPortfolios < ActiveRecord::Migration[5.2]
  def change
    create_table :account_portfolios do |t|
      t.references :account, index: true, foreign_key: true, null: false
      t.references :portfolio, index: true, foreign_key: true, null: false

      t.timestamps null: false

      t.index [:account_id, :portfolio_id], unique: true
    end
  end
end
