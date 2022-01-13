class AddRootToPackerReport < ActiveRecord::Migration[5.2]
  def change
    add_column :packer_reports, :root, :string
  end
end
