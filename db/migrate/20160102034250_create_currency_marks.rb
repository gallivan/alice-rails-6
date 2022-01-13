class CreateCurrencyMarks < ActiveRecord::Migration[5.2]
  def change
    create_table :currency_marks do |t|
      t.integer :currency_id
      t.date :posted_on
      t.decimal :mark

      t.timestamps null: false
    end
    add_index :currency_marks, :posted_on
    add_index :currency_marks, :currency_id
    add_index :currency_marks, [:currency_id, :posted_on], unique: true, name: 'currency_marks_uq'
  end
end
