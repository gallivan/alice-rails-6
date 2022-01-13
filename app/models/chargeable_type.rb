# == Schema Information
#
# Table name: chargeable_types
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  name       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class ChargeableType < ApplicationRecord
  validates :code, presence: true
  validates :name, presence: true

  has_many :chargeables

  def self.select_options
    select("id, code").order(:code).all.collect { |a| [a.code, a.id] }
  end

  # could probably build these via meta-programming

  def enm?
    self.code == 'ENM'
  end

  def exchange_non_member?
    self.enm?
  end

  def exg?
    self.code == 'EXG'
  end

  def exchange?
    self.exg?
  end
end
