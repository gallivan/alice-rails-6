class CreateClaimTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :claim_types do |t|
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :claim_types, :code, unique: true, name: 'claim_type_code_uq'
    add_index :claim_types, :name, unique: true, name: 'claim_type_name_uq'
  end
end
