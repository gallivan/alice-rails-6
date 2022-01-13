class CreateCcyOtes < ActiveRecord::Migration[5.2]
  def change
    create_view :ccy_otes
  end
end
