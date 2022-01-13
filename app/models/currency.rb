# == Schema Information
#
# Table name: currencies
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Currency < ApplicationRecord
  validates :code, presence: true, uniqueness: true
  validates :name, presence: true, uniqueness: true

  SUPPORTED = {
      aud: {code: 'AUD', name: 'Australian Dollar'},
      cad: {code: 'CAD', name: 'Canadian Dollar'},
      chf: {code: 'CHF', name: 'Swiss Franc'},
      dkk: {code: 'DKK', name: 'Danish Kroner'},
      eur: {code: 'EUR', name: 'Euro'},
      gbp: {code: 'GBP', name: 'British Pound'},
      jpy: {code: 'JPY', name: 'Japanese Yen'},
      nok: {code: 'NOK', name: 'Norwegian Krone'},
      sgd: {code: 'SGD', name: 'Singapore Dollar'},
      sek: {code: 'SEK', name: 'Swedish Kroner'},
      ukn: {code: 'UKN', name: 'Unknown Currency'},
      usd: {code: 'USD', name: 'United States Dollar'}
  }

  has_many :claims, foreign_key: :point_currency_id
  has_many :chargeables
  has_many :currency_marks

  scope :aud, -> { where(code: 'EUR').first }
  scope :cad, -> { where(code: 'CAD').first }
  scope :chf, -> { where(code: 'CHF').first }
  scope :dkk, -> { where(code: 'DKK').first }
  scope :eur, -> { where(code: 'EUR').first }
  scope :gbp, -> { where(code: 'GBP').first }
  scope :jpy, -> { where(code: 'JPY').first }
  scope :sgd, -> { where(code: 'SGD').first }
  scope :sek, -> { where(code: 'SEK').first }
  scope :nok, -> { where(code: 'NOK').first }
  scope :ukn, -> { where(code: 'UKN').first }
  scope :usd, -> { where(code: 'USD').first }

  def self.select_options
    select("id, code").order(:code).all.collect { |a| [a.code, a.id] }
  end

end
