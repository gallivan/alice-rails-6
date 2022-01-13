# == Schema Information
#
# Table name: deal_leg_fills
#
#  id                    :integer          not null, primary key
#  deal_leg_id           :integer
#  system_id             :integer          not null
#  dealing_venue_id      :integer          not null
#  dealing_venue_done_id :string           not null
#  account_id            :integer
#  claim_id              :integer
#  done                  :decimal(, )      not null
#  price                 :decimal(, )      not null
#  price_traded          :string           not null
#  posted_on             :date             not null
#  traded_on             :date             not null
#  traded_at             :datetime         not null
#  position_id           :integer
#  booker_report_id      :integer
#  kind                  :string           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#

class DealLegFill < ApplicationRecord
  # validates :deal_leg_id, presence: true # Association not currently implemented: Deal and DealLeg not created.
  validates :kind, presence: true, inclusion: {in: %w(META DATA), message: "%{value} is not a valid type signifier"}
  validates :done, presence: true
  validates :price, presence: true
  validates :price_traded, presence: true
  validates :posted_on, presence: true
  validates :traded_on, presence: true
  validates :traded_at, presence: true
  validates :system_id, presence: true
  validates :dealing_venue_id, presence: true
  validates :dealing_venue_done_id, presence: true

  belongs_to :claim
  belongs_to :system
  belongs_to :account
  belongs_to :position
  # belongs_to :deal_leg
  belongs_to :dealing_venue
  # belongs_to :booker_report ### need to enfoce this some how but allow for manual entry.

  scope :posted_on, -> (posted_on) { where(posted_on: posted_on) }
  scope :traded_on, -> (traded_on) { where(traded_on: traded_on) }

  scope :for_claim, ->(claim_id) {
    where("claim_id = ?", claim_id)
  }

  scope :bot, -> {where('done > 0')}
  scope :sld, -> {where('done < 0')}

  # def self.search(params)
  #   params[:page] = 1 if params[:page].blank?
  #   puts params.inspect
  #   account = Account.find_by_code('03000')
  #   posted_on = params['posted_on'].blank? ? DealLegFill.maximum(:posted_on) : Date.parse(params['posted_on'])
  #   account.blank? ? [] : account.deal_leg_fills.posted_on(posted_on).joins(:contract).order([:posted_on, :id]).page(params[:page])
  # end

  before_destroy do
    raise "Position closed. Cannot delete DealLegFill." if position.closed?
    position.reverse_deal_leg_fill(self)
  end

  after_destroy do
    raise "Position closed. Cannot delete Position." if position.closed?
    position.destroy if position.bot_and_sld_flat?
  end

end
