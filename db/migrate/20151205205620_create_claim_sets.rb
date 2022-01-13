class CreateClaimSets < ActiveRecord::Migration[5.2]
  def change
    create_table :claim_sets do |t|
      t.string :code
      t.string :name

      t.timestamps null: false
    end
    add_index :claim_sets, [:code], unique: true, name: :claim_set_uq
  end
end
