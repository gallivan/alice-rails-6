# == Schema Information
#
# Table name: quickfix_messages
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
#  msgseqnum         :integer
#  message           :text
#  created_at        :datetime
#  updated_at        :datetime
#

class QuickfixMessage < ApplicationRecord
end
