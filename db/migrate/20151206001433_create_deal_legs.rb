class CreateDealLegs < ActiveRecord::Migration[5.2]
  def change
    create_table :deal_legs do |t|
      t.integer :deal_id, null: false
      t.integer :claim_id, null: false
      t.integer :sort
      t.decimal :todo, null: false
      t.decimal :done
      t.decimal :todo_price
      t.decimal :done_price

      t.timestamps null: false
    end
    add_foreign_key :deal_legs, :deals, name: 'deal_leg_deal_fk'
    add_foreign_key :deal_legs, :claims, name: 'deal_leg_claim_fk'
  end
end
