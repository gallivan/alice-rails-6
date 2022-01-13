# == Schema Information
#
# Table name: quickfix_incoming_log_lines
#
#  id                :bigint           not null, primary key
#  time              :datetime
#  beginstring       :string
#  sendercompid      :string
#  sendersubid       :string
#  senderlocid       :string
#  targetcompid      :string
#  targetsubid       :string
#  targetlocid       :string
#  session_qualifier :string
#  text              :text
#  created_at        :datetime
#  updated_at        :datetime
#

class QuickfixIncomingLogLine < ApplicationRecord
end
