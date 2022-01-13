class AddPriceTradedToStatementPositions < ActiveRecord::Migration[5.2]
  def change
    add_column :statement_positions, :price_traded, :string
  end
end
