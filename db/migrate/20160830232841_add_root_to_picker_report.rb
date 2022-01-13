class AddRootToPickerReport < ActiveRecord::Migration[5.2]
  def change
    add_column :picker_reports, :root, :string
  end
end
