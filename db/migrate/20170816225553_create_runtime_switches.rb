class CreateRuntimeSwitches < ActiveRecord::Migration[5.2]
  def change
    create_table :runtime_switches do |t|
      t.string :name, null: false, unique: true
      t.boolean :is_on, null: false
      t.string :note, null: false

      t.timestamps null: false
    end
  end
end
