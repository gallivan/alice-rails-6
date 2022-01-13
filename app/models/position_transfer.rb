# == Schema Information
#
# Table name: position_transfers
#
#  id             :integer          not null, primary key
#  fm_position_id :integer          not null
#  to_position_id :integer          not null
#  bot_transfered :decimal(, )      not null
#  sld_transfered :decimal(, )      not null
#  user_id        :integer          not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#

class PositionTransfer < ApplicationRecord
  validates :fm_position_id, presence: true
  validates :to_position_id, presence: true
  validates :bot_transfered, presence: true
  validates :sld_transfered, presence: true
  validates :user_id, presence: true

  belongs_to :fm_position, class_name: 'Position'
  belongs_to :to_position, class_name: 'Position'
  belongs_to :user

  attr_accessor :fm_account
  attr_accessor :to_account_id
end
