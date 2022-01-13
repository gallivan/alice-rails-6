# == Schema Information
#
# Table name: claim_sub_types
#
#  id         :integer          not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ClaimSubType < ApplicationRecord
end
