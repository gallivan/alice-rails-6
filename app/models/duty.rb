# == Schema Information
#
# Table name: duties
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Duty < ApplicationRecord
  has_many :user_duties
  has_many :users, through: :user_duties
end
