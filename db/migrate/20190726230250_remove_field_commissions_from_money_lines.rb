class RemoveFieldCommissionsFromMoneyLines < ActiveRecord::Migration[5.2]
  def change
    remove_column :money_lines, :commissions, :number
  end
end
