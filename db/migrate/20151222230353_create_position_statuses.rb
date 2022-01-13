class CreatePositionStatuses < ActiveRecord::Migration[5.2]
  def change
    create_table :position_statuses do |t|
      t.string :code, null: false
      t.string :name, null: false

      t.timestamps null: false
    end
    add_index :position_statuses, :code, unique: true, name: 'position_status_code_uq'
    add_index :position_statuses, :name, unique: true, name: 'position_status_name_uq'
  end
end
