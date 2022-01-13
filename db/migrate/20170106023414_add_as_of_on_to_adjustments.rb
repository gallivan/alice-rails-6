class AddAsOfOnToAdjustments < ActiveRecord::Migration[5.2]
  def change
    add_column :adjustments, :as_of_on, :date
  end
end
