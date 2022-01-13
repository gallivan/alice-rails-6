class CreateSpreads < ActiveRecord::Migration[5.2]
  def change
    create_table :spreads do |t|
      t.integer :claimable_id
      t.string :code, unique: true, null: false
      t.string :name, unique: true, null: false

      t.timestamps null: false
    end
    add_foreign_key :spreads, :claims, column: :claimable_id, name: 'spread_claimable_fk'
  end
end