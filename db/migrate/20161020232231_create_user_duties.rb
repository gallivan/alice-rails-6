class CreateUserDuties < ActiveRecord::Migration[5.2]
  def change
    create_table :user_duties do |t|
      t.references :user, index: true, foreign_key: true
      t.references :duty, index: true, foreign_key: true

      t.timestamps null: false
    end
    add_index :user_duties, [:user_id, :duty_id], unique: true
  end
end
