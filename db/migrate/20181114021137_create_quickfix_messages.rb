class CreateQuickfixMessages < ActiveRecord::Migration[5.2]
  def change
    create_table :quickfix_messages do |t|
      t.string :beginstring
      t.string :sendercompid
      t.string :sendersubid
      t.string :senderlocid
      t.string :targetcompid
      t.string :targetsubid
      t.string :targetlocid
      t.string :session_qualifier
      t.integer :msgseqnum
      t.text :message

      t.timestamp :created_at, null: true
      t.timestamp :updated_at, null: true
    end

    add_index :quickfix_messages, [:beginstring, :sendercompid, :sendersubid, :senderlocid,
      				:targetcompid, :targetsubid, :targetlocid, :session_qualifier, :msgseqnum],
              unique: true, name: :quickfix_messages_uq
  end
end
