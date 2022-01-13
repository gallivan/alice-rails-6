class CreateHeldByExgCcyOtes < ActiveRecord::Migration[5.2]
  def change
    create_view :held_by_exg_ccy_otes
  end
end
