class CreateClaims < ActiveRecord::Migration[5.2]
  def change
    create_table :claims do |t|
      t.integer :claim_set_id, null: false
      t.integer :claim_type_id, null: false
      t.integer :entity_id
      t.integer :claimable_id, null: false
      t.string :claimable_type, null: false
      t.string :code, null: false
      t.string :name, null: false
      t.decimal :size, null: false, default: 1
      t.decimal :point_value, null: false, default: 1
      t.integer :point_currency_id, null: false

      t.timestamps null: false
    end
    add_index :claims, [:claimable_id, :claimable_type], unique: true, name: 'claim_uq'
    add_index :claims, [:entity_id, :code], unique: true, name: 'claim_entity_code_uq'

    add_foreign_key :claims, :claim_types, name: 'claim_claim_type_fk'
    add_foreign_key :claims, :claim_sets, name: 'claim_claim_set_fk'
    add_foreign_key :claims, :entities, name: 'claim_entity_fk'
    add_foreign_key :claims, :currencies, name: 'claim_point_currency_fk', column: :point_currency_id
  end
end
