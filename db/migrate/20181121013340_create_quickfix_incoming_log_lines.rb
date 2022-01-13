class CreateQuickfixIncomingLogLines < ActiveRecord::Migration[5.2]
  def change
    create_table :quickfix_incoming_log_lines do |t|
      t.timestamp :time
      t.string :beginstring
      t.string :sendercompid
      t.string :sendersubid
      t.string :senderlocid
      t.string :targetcompid
      t.string :targetsubid
      t.string :targetlocid
      t.string :session_qualifier
      t.text :text

      t.timestamp :created_at, null: true
      t.timestamp :updated_at, null: true
    end
  end
end
