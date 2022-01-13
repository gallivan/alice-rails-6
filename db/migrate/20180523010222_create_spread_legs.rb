class CreateSpreadLegs < ActiveRecord::Migration[5.2]
  def change
    create_table :spread_legs do |t|
      t.references :spread, index: true, foreign_key: true
      t.references :claim, index: true, foreign_key: true
      t.integer :weight

      t.timestamps
    end
  end
end
