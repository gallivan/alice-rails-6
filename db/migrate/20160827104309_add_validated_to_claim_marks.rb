class AddValidatedToClaimMarks < ActiveRecord::Migration[5.2]
  def up
    add_column :claim_marks, :approved, :boolean
    ClaimMark.update_all(approved: false)
    change_column :claim_marks, :approved, :boolean, null: false
  end

  def down
    remove_column :claim_marks, :approved
  end
end
