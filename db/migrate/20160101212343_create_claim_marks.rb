class CreateClaimMarks < ActiveRecord::Migration[5.2]
  def change
    create_table :claim_marks do |t|
      t.integer :system_id
      t.integer :claim_id
      t.date :posted_on
      t.decimal :mark

      t.timestamps null: false
    end
    add_index :claim_marks, [:system_id, :claim_id, :posted_on], unique: true, name: :claim_marks_uq

    add_foreign_key :claim_marks, :claims, name: :claim_mark_claim_fk
    add_foreign_key :claim_marks, :systems, name: :claim_mark_system_fk
  end
end
