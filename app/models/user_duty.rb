# == Schema Information
#
# Table name: user_duties
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  duty_id    :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class UserDuty < ApplicationRecord
  belongs_to :user
  belongs_to :duty
end
