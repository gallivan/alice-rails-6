class CreateClaimSetAliases < ActiveRecord::Migration[5.2]
  def change
    create_table :claim_set_aliases do |t|
      t.integer :system_id, null: false
      t.integer :claim_set_id, null: false
      t.string :code, null: false

      t.timestamps null: false
    end
    add_index :claim_set_aliases, [:system_id, :claim_set_id], unique: true

    add_foreign_key :claim_set_aliases, :systems, name: 'claim_set_alias_system_fk'
    add_foreign_key :claim_set_aliases, :claim_sets, name: 'claim_set_alias_claim_set_fk'
  end
end
