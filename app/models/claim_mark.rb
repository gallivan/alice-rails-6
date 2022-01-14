# == Schema Information
#
# Table name: claim_marks
#
#  id          :integer          not null, primary key
#  system_id   :integer
#  claim_id    :integer
#  posted_on   :date
#  mark        :decimal(, )
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#  approved    :boolean          not null
#  mark_traded :string
#  open        :decimal(16, 8)
#  high        :decimal(16, 8)
#  low         :decimal(16, 8)
#  last        :decimal(16, 8)
#  change      :decimal(16, 8)
#  volume      :integer
#  interest    :integer
#

class ClaimMark < ApplicationRecord
  validates :system_id, presence: true
  validates :claim_id, presence: true
  validates :posted_on, presence: true
  validates :mark, presence: true

  belongs_to :claim
  belongs_to :system

  scope :posted_on, ->(posted_on) {
    where("posted_on = ?", posted_on)
  }

  scope :posted_for, ->(claim_id) {
    where("claim_id = ?", claim_id)
  }

  scope :cme, -> {
    joins(:claim => :entity).where("entities.code = 'CME'")
  }

  scope :cbt, -> {
    joins(:claim => :entity).where("entities.code = 'CBT'")
  }

  def self.post_mark(params)
    filter = params.select { |key, val| key.to_s.match(/^(system_id|claim_id|posted_on)$/) }
    claim = ClaimMark.where(filter).first
    if claim.blank?
      create! do |m|
        m.system_id = params[:system_id]
        m.claim_id = params[:claim_id]
        m.posted_on = params[:posted_on]
        m.mark = params[:mark]
        m.approved = params[:approved]
      end
    else
      claim.update(:mark, params[:mark])
    end
  end

  def approved?
    approved
  end

  def self.claims_to_mark_for_date(date)
    claims = []
    claim_ids = Position.posted_on_or_before(date).open.pluck(:claim_id).uniq.sort
    claim_ids.each do |id|
      claims << Claim.find(id)
    end
    claims
  end

  def self.missing_marks_for_date?(date, claims)
    missed = []
    claims.each do |claim|
      missed << claim if claim.claim_marks.posted_on(date).blank?
    end
    if missed.empty?
      false
    else
      missed.each do |claim|
        msg = "ClaimMark missing for #{claim.code} for date #{date}"
        Rails.logger.warn msg
        puts msg
      end
    end
  end

  def self.move_marks(date)
    puts "Getting claim marks for #{date}"

    claim_ids = DealLegFill.uniq.pluck(:claim_id)

    claim_ids.each do |claim_id|
      claim = Claim.find(claim_id)
      mark = ClaimMark.posted_on(date).posted_fo(claim_id).first
      if mark.blank?
        price = DealLegFill.for_claim(claim_id).pluck(:price).uniq.sample
        puts "Posting mark price for #{claim.code} of #{price}"
        ClaimMark.create! do |s|
          s.system_id = System.find_by_code('QDL').id
          s.claim_id = claim_id
          s.posted_on = date
          s.mark = price
        end
      else
        fill = DealLegFill.for_claim(claim_id).last
        puts "Updating mark price for #{claim.code} of #{fill.price}"
        mark.update(:mark, fill.price)
      end
    end
  end

end
