# == Schema Information
#
# Table name: positions
#
#  id                 :integer          not null, primary key
#  account_id         :integer          not null
#  claim_id           :integer          not null
#  posted_on          :date             not null
#  traded_on          :date             not null
#  price              :decimal(, )      not null
#  price_traded       :string           not null
#  bot                :decimal(, )      default(0.0), not null
#  sld                :decimal(, )      default(0.0), not null
#  bot_off            :decimal(, )      default(0.0), not null
#  sld_off            :decimal(, )      default(0.0), not null
#  net                :decimal(, )      default(0.0), not null
#  mark               :decimal(, )
#  ote                :decimal(, )
#  currency_id        :integer          not null
#  position_status_id :integer          not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Position < ApplicationRecord
  validates :posted_on, presence: true
  validates :traded_on, presence: true
  validates :account_id, presence: true
  validates :claim_id, presence: true
  validates :price, presence: true
  validates :price_traded, presence: true
  validates :bot, presence: true
  validates :sld, presence: true
  validates :bot_off, presence: true
  validates :sld_off, presence: true
  validates :currency_id, presence: true
  validates :position_status_id, presence: true

  belongs_to :claim
  belongs_to :account
  belongs_to :currency
  belongs_to :position_status

  has_many :deal_leg_fills

  has_many :portfolio_positions
  has_many :portfolios, through: :portfolio_positions


  scope :posted_on, -> (posted_on) {where(posted_on: posted_on)}
  scope :posted_on_or_before, -> (posted_on) {where("posted_on <= ?", posted_on)}
  scope :with_claim_id, -> (claim_id) {where(claim_id: claim_id)}

  scope :open, -> {
    joins(:position_status).
        where("position_statuses.code = 'OPN'")
  }

  scope :closed, -> {
    joins(:position_status).
        where("position_statuses.code = 'CLO'")
  }

  scope :bots, -> {
    where("bot > 0")
  }

  scope :slds, -> {
    where("sld > 0")
  }

  scope :cme_core_marginable, -> {
    joins(:claim => :entity).where("entities.code in ('CME', 'CBT', 'NYMEX')")
  }

  scope :cme, -> {
    joins(:claim => :entity).where("entities.code = 'CME'")
  }

  scope :cbt, -> {
    joins(:claim => :entity).where("entities.code = 'CBT'")
  }

  before_destroy do
    raise "Cannot destroy closed Position." if closed?
  end

  def compute_ote(date)
    # puts '*' * 20
    # puts self.inspect
    # puts self.claim.inspect

    claim_mark = self.claim.claim_marks.posted_on(date).first
    mark = claim_mark.mark

    if bot == 0 and sld == 0
      self.ote = 0
    else
      mul = claim.point_value

      if bot > 0
        pay = (BigDecimal(price.to_s, 16) * BigDecimal(mul.to_s, 16)).round(2)
        rec = (BigDecimal(mark.to_s, 16) * BigDecimal(mul.to_s, 16)).round(2)
        self.ote = (bot * (rec - pay)).round(2)
      end

      if sld > 0
        pay = (BigDecimal(mark.to_s, 16) * BigDecimal(mul.to_s, 16)).round(2)
        rec = (BigDecimal(price.to_s, 16) * BigDecimal(mul.to_s, 16)).round(2)
        self.ote = (sld * (rec - pay)).round(2)
      end

      # self.ote = bot * (mark - price) * claim.point_value if bot > 0
      # self.ote = sld * (price - mark) * claim.point_value if sld > 0
      # self.ote = self.ote.round(2)
    end

    # puts "posted_on: #{self.posted_on}"
    # puts "claim.code: #{self.claim.code}"
    # puts "bot: #{self.bot}"
    # puts "sld: #{self.sld}"
    # puts "price: #{self.price}"
    # puts "mark: #{mark}"
    # puts "claim.point_value: #{self.claim.point_value}"
    # puts "ote: #{self.ote}"

    self.update_attributes(ote: self.ote, currency_id: self.currency_id, mark: mark)
  end

  def net!
    update_attribute(:net, bot - sld)
  end

  def close!
    update_attribute(:position_status, PositionStatus.find_by_code('CLO'))
  end

  def open?
    position_status.code == 'OPN'
  end

  def closed?
    position_status.code == 'CLO'
  end

  def flat?
    net == 0
  end

  def bot_flat?
    bot == 0
  end

  def sld_flat?
    sld == 0
  end

  def bot_and_sld_flat?
    bot_flat? and sld_flat?
  end

  def reverse_deal_leg_fill(deal_leg_fill)
    raise "Position closed. Cannot reverse Position impact destroy DealLegFill." if self.closed?
    raise "Position bot smaller than DealLegFill done for bot. Cannot reverse Position impact and destroy DealLegFill." if deal_leg_fill.done > 0 and deal_leg_fill.done > self.bot
    raise "Position sld smaller than DealLegFill done for sld. Cannot reverse Position impact and destroy DealLegFill." if deal_leg_fill.done < 0 and deal_leg_fill.done.abs > self.sld

    ActiveRecord::Base.transaction do
      if deal_leg_fill.done > 0
        self.update_attribute(:bot, self.bot - deal_leg_fill.done)
      else
        self.update_attribute(:sld, self.sld - deal_leg_fill.done.abs)
      end

      self.update_attribute(:net, self.bot - self.sld)

    end
  end

  before_destroy do
    raise "Position closed. Cannot delete DealLegFill." if self.closed?
    key = "#{self.account_id}:#{self.claim_id}:#{self.posted_on}:#{self.traded_on}:#{self.price}"
    Rails.cache.delete_matched key
  end

end
