class CreateMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :messages do |t|
      t.string :source, null: false
      t.string :format, null: false
      t.string :head
      t.text :body, null: false
      t.string :tail
      t.string :handler
      t.boolean :handled, null: false, default: false
      t.text :error

      t.timestamps null: false
    end
    add_index :messages, :source
    add_index :messages, :handled
  end
end
