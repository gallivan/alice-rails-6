class CreateUsdOtes < ActiveRecord::Migration[5.2]
  def change
    create_view :usd_otes
  end
end
