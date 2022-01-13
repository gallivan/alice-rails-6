class AddRootToBookerReport < ActiveRecord::Migration[5.2]
  def change
    add_column :booker_reports, :root, :string
  end
end
