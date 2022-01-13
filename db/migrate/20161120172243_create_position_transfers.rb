class CreatePositionTransfers < ActiveRecord::Migration[5.2]
  def change
    create_table :position_transfers do |t|
      t.integer :fm_position_id, null: false
      t.integer :to_position_id, null: false
      t.decimal :bot_transfered, null: false
      t.decimal :sld_transfered, null: false
      t.integer :user_id, null: false

      t.timestamps null: false
    end
    add_foreign_key :position_transfers, :users, name: :position_transfer_user_fk
    add_foreign_key :position_transfers, :positions, column: :fm_position_id, name: :position_transfers_fm_position_fk
    add_foreign_key :position_transfers, :positions, column: :to_position_id, name: :position_transfers_to_position_fk
  end
end
