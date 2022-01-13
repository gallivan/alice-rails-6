class CreateFutures < ActiveRecord::Migration[5.2]
  def change
    create_table :futures do |t|
      t.integer :claimable_id#, null: false
      t.date :expiration_date, null: false
      t.string :code

      t.timestamps null: false
    end
    add_foreign_key :futures, :claims, column: :claimable_id, name: 'future_claimable_fk'
  end
end
