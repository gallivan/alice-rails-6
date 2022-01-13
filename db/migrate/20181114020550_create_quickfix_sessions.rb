class CreateQuickfixSessions < ActiveRecord::Migration[5.2]
  def change
    create_table :quickfix_sessions do |t|
      t.string :beginstring
      t.string :sendercompid
      t.string :sendersubid
      t.string :senderlocid
      t.string :targetcompid
      t.string :targetsubid
      t.string :targetlocid
      t.string :session_qualifier
      t.timestamp :creation_time
      t.integer :incoming_seqnum
      t.integer :outgoing_seqnum

      t.timestamp :created_at, null: true
      t.timestamp :updated_at, null: true
    end

    add_index :quickfix_sessions, [:beginstring, :sendercompid, :sendersubid, :senderlocid,
      				:targetcompid, :targetsubid, :targetlocid, :session_qualifier],
              unique: true, name: :quickfix_sessions_uq
  end
end
