class CreateClaimSubTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :claim_sub_types do |t|
      t.string :code
      t.string :name

      t.timestamps null: false
    end
    add_index :claim_sub_types, :code, unique: true, name: 'claim_sub_type_code_uq'
    add_index :claim_sub_types, :name, unique: true, name: 'claim_sub_type_name_uq'
  end
end
