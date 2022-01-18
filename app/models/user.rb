# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  reset_password_token   :string
#  reset_password_sent_at :datetime
#  remember_created_at    :datetime
#  sign_in_count          :integer          default(0), not null
#  current_sign_in_at     :datetime
#  last_sign_in_at        :datetime
#  current_sign_in_ip     :inet
#  last_sign_in_ip        :inet
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#  name                   :string
#

class User < ApplicationRecord

  include ActiveModel::Validations

  # validates :password, password_strength: {use_dictionary: true, min_word_length: 8, min_entropy: 40}}
  validates :password, password_strength: {use_dictionary: true, min_entropy: 30}

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable, :recoverable, :rememberable, :trackable, :validatable

  has_many :managed_accounts #, :dependent => :delete_all
  has_many :accounts, through: :managed_accounts

  has_many :user_duties #, :dependent => :delete_all
  has_many :duties, through: :user_duties

  def to_s
    email
  end

  def has_duty?(duty)
    duties.include?(duty)
  end

  def is_root?
    duties.pluck(:code).include?('ROOT')
  end

  def is_back_officer?
    duties.pluck(:code).include?('BACK')
  end

  def is_head_trader?
    duties.pluck(:code).include?('HEAD')
  end

  def is_trader?
    duties.pluck(:code).include?('TRADER')
  end

  def is_risk_manager?
    duties.pluck(:code).include?('RISK')
  end

  def is_compliance_officer?
    duties.pluck(:code).include?('COMP')
  end

  def can_see_all_accounts?
    is_back_officer? or is_head_trader? or is_risk_manager? or is_compliance_officer? or is_root?
  end

  def has_accounts?
    accounts.count > 0
  end

  def account_select_options
    # Account.active.where("code not in ('ZZZZZ')").select("id, code, origin").order(:origin, :code).all.collect { |a| [" #{a.code}:0#{a.origin} ", a.id] }

    # TODO - something role/pundit based

    if is_trader? or duties.blank?
      accounts.active.select("accounts.id, accounts.code").order(:code).all.collect {|a| [" #{a.code}", a.id]}
    else
      Account.active.select("id, code").order(:code).all.collect {|a| [" #{a.code}", a.id]}
    end
  end

  def first_name
    name.nil? ? nil : name.split.first
  end

  def last_name
    name.nil? ? nil : name.split.last
  end

  def middle_name
    return nil if name.nil?
    name.split.count > 2 ? name.split.slice(1..-2).join(' ') : nil
  end

end
