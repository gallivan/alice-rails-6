class CreateRuntimeKnobs < ActiveRecord::Migration[5.2]
  def change
    create_table :runtime_knobs do |t|
      t.string :name, null: false, unique: true
      t.string :tick, null: false
      t.string :note, null: false

      t.timestamps null: false
    end
  end
end
