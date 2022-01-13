# == Schema Information
#
# Table name: claim_sets
#
#  id         :integer          not null, primary key
#  code       :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  sector     :string
#

class ClaimSet < ApplicationRecord
  validates :code, presence: true
  validates :name, presence: true

  has_many :claims
  has_many :chargeables

  scope :spreads, -> {
    joins(:claims => :claim_type).where("claim_types.code = 'SPD'")
  }

  # scope :with_admin, -> {joins(:feed => {:groups => :user}).where('users.admin' => true)}

  def self.select_options_by_code
    select("id, code").order(:code).all.collect {|a| [" #{a.code}", a.id]}
  end

  def self.select_options_by_name
    select("id, name").order(:name).all.collect {|a| [" #{a.name}", a.id]}
  end
end
