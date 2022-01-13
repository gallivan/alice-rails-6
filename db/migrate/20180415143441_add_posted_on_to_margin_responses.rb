class AddPostedOnToMarginResponses < ActiveRecord::Migration[5.2]
  def change
    add_column :margin_responses, :posted_on, :date
  end
end
