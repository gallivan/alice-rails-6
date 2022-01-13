class CreateMonies < ActiveRecord::Migration[5.2]
  def change
    create_table :monies do |t|
      t.integer :claimable_id#, null: false
      t.integer :currency_id, null: false
      t.date :settled_on, null: false

      t.timestamps null: false
    end
    add_foreign_key :monies, :claims, column: :claimable_id, name: 'money_claimable_fk'
  end
end
