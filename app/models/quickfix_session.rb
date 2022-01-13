# == Schema Information
#
# Table name: quickfix_sessions
#
#  id                :bigint           not null, primary key
#  beginstring       :string
#  sendercompid      :string
#  sendersubid       :string
#  senderlocid       :string
#  targetcompid      :string
#  targetsubid       :string
#  targetlocid       :string
#  session_qualifier :string
#  creation_time     :datetime
#  incoming_seqnum   :integer
#  outgoing_seqnum   :integer
#  created_at        :datetime
#  updated_at        :datetime
#

class QuickfixSession < ApplicationRecord
end
