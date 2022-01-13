# == Schema Information
#
# Table name: messages
#
#  id         :integer          not null, primary key
#  source     :string           not null
#  format     :string           not null
#  head       :string
#  body       :text             not null
#  tail       :string
#  handler    :string
#  handled    :boolean          default(FALSE), not null
#  error      :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Message < ApplicationRecord
  validates :source, presence: true
  validates :format, presence: true
  validates :body, presence: true
end
