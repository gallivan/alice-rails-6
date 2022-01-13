# == Schema Information
#
# Table name: position_nettings
#
#  id                       :integer          not null, primary key
#  account_id               :integer          not null
#  currency_id              :integer          not null
#  claim_id                 :integer          not null
#  position_netting_type_id :integer          not null
#  bot_position_id          :integer          not null
#  sld_position_id          :integer          not null
#  posted_on                :date             not null
#  done                     :decimal(, )      not null
#  bot_price                :decimal(, )      not null
#  sld_price                :decimal(, )      not null
#  bot_price_traded         :string           not null
#  sld_price_traded         :string           not null
#  pnl                      :decimal(, )      not null
#  created_at               :datetime         not null
#  updated_at               :datetime         not null
#

class PositionNetting < ApplicationRecord
  validates :currency_id, presence: true
  validates :account_id, presence: true
  validates :claim_id, presence: true
  validates :posted_on, presence: true
  validates :position_netting_type_id, presence: true
  validates :bot_position_id, presence: true
  validates :sld_position_id, presence: true
  validates :bot_price, presence: true
  validates :sld_price, presence: true
  validates :bot_price_traded, presence: true
  validates :sld_price_traded, presence: true
  validates :done, presence: true
  validates :pnl, presence: true

  belongs_to :claim
  belongs_to :account
  belongs_to :currency
  belongs_to :position_netting_type
  belongs_to :bot_position, class_name: 'Position'
  belongs_to :sld_position, class_name: 'Position'

  scope :scratch, -> {
    joins(:position_netting_type).
        where("position_netting_types.code = 'SCH'")
  }

  scope :day, -> {
    joins(:position_netting_type).
        where("position_netting_types.code = 'DAY'")
  }

  scope :overnight, -> {
    joins(:position_netting_type).
        where("position_netting_types.code = 'OVR'")
  }

  scope :posted_on, -> (posted_on) { where(posted_on: posted_on) }
end
