class CreateViewPoints < ActiveRecord::Migration[5.2]
  def change
    create_table :view_points do |t|
      t.string :name
      t.text :note
      t.text :code

      t.timestamps null: false
    end
  end
end
