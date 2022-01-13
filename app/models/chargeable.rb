# == Schema Information
#
# Table name: chargeables
#
#  id                 :integer          not null, primary key
#  chargeable_type_id :integer          not null
#  claim_set_id       :integer          not null
#  currency_id        :integer          not null
#  amount             :decimal(, )      not null
#  begun_on           :date             not null
#  ended_on           :date             not null
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class Chargeable < ApplicationRecord
  validates :chargeable_type_id, presence: true
  validates :claim_set_id, presence: true
  validates :currency_id, presence: true
  validates :amount, presence: true
  validates :begun_on, presence: true
  validates :ended_on, presence: true

  belongs_to :chargeable_type
  belongs_to :claim_set
  belongs_to :currency

  has_many :charges

  scope :clearing, -> {
    joins(:chargeable_type).
        where("chargeable_types.code = 'CLR'")
  }

  scope :exchange, -> {
    joins(:chargeable_type).
        where("chargeable_types.code = 'EXG'")
  }

  scope :service, -> {
    joins(:chargeable_type).
        where("chargeable_types.code = 'SRV'")
  }

  scope :brokerage, -> {
    joins(:chargeable_type).
        where("chargeable_types.code = 'BRK'")
  }

  scope :exchange_non_member, -> {
    joins(:chargeable_type).
        where("chargeable_types.code = 'ENM'")
  }

end
