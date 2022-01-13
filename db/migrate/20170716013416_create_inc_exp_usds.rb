class CreateIncExpUsds < ActiveRecord::Migration[5.2]
  def change
    create_view :inc_exp_usds
  end
end
