class AddPostedOnToMargins < ActiveRecord::Migration[5.2]
  def change
    add_column :margins, :posted_on, :date
  end
end
