class CreateClaimAliases < ActiveRecord::Migration[5.2]
  def change
    create_table :claim_aliases do |t|
      t.integer :system_id, null: false
      t.integer :claim_id, null: false
      t.string :code, null: false

      t.timestamps null: false
    end
    add_index :claim_aliases, [:system_id, :claim_id], unique: true

    add_foreign_key :claim_aliases, :claims, name: :claim_alias_claim_fk
    add_foreign_key :claim_aliases, :systems, name: :claim_alias_system_fk
  end
end
