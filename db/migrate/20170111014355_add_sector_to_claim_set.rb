class AddSectorToClaimSet < ActiveRecord::Migration[5.2]
  def change
    add_column :claim_sets, :sector, :string
  end
end
