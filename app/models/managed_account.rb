# == Schema Information
#
# Table name: managed_accounts
#
#  id         :integer          not null, primary key
#  user_id    :integer          not null
#  account_id :integer          not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ManagedAccount < ApplicationRecord
  belongs_to :user
  belongs_to :account
end
