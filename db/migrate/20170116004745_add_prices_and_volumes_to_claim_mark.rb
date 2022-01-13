class AddPricesAndVolumesToClaimMark < ActiveRecord::Migration[5.2]
  def change
    add_column :claim_marks, :open, :decimal, precision: 16, scale: 8
    add_column :claim_marks, :high, :decimal, precision: 16, scale: 8
    add_column :claim_marks, :low, :decimal, precision: 16, scale: 8
    add_column :claim_marks, :last, :decimal, precision: 16, scale: 8
    add_column :claim_marks, :change, :decimal, precision: 16, scale: 8
    add_column :claim_marks, :volume, :integer
    add_column :claim_marks, :interest, :integer
  end
end
