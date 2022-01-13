class AddPostedOnToMarginRequests < ActiveRecord::Migration[5.2]
  def change
    add_column :margin_requests, :posted_on, :date
  end
end
