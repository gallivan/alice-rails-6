class AddMarkTradedToClaimMarks < ActiveRecord::Migration[5.2]
  def change
    add_column :claim_marks, :mark_traded, :string
  end
end
