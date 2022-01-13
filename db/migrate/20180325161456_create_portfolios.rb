class CreatePortfolios < ActiveRecord::Migration[5.2]
  def change
    create_table :portfolios do |t|
      t.string :code, null: false
      t.string :name, null: false
      t.string :note
      t.date :posted_on, null: false

      t.timestamps null: false
    end
  end
end
