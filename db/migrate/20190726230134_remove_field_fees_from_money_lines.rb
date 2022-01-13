class RemoveFieldFeesFromMoneyLines < ActiveRecord::Migration[5.2]
  def change
    remove_column :money_lines, :fees, :number
  end
end
