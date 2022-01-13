# == Schema Information
#
# Table name: runtime_switches
#
#  id         :integer          not null, primary key
#  name       :string           not null
#  is_on      :boolean          not null
#  note       :string           not null
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class RuntimeSwitch < ApplicationRecord
  validates :name, presence: true
  validates :note, presence: true
  # validates :is_on, presence: true # commented out because ActiveAdmin uses 1 and 0 - which generates nil on save

  def self.is_on?(name)
    name = name.to_s if name.is_a?(Symbol)
    switch = where(name: name).first
    (switch.blank?) ? false : switch.is_on?
  end

  def self.is_off?(name)
    not is_on?(name)
  end

  def self.all_found?
    search = [
        :load_abn_activity,
        :send_large_trader_report_to_cftc,
        :send_large_trader_report_to_cme,
        :send_statement,
        :send_statement_summary
    ]

    found = RuntimeSwitch.all.pluck(:name).map {|name| name.to_sym}.sort

    if (search - found).empty?
      true
    else
      msg = "RuntimeSwitch missing: #{search - found}."
      Rails.logger.warn msg
      EodMailer.alert(msg).deliver_now
      false
    end
  end

  def self.set_off(name)
    runtime_switch = find_by_name(name)
    runtime_switch.is_on = false
    runtime_switch.save!
  end

  def self.set_on(name)
    runtime_switch = find_by_name(name)
    runtime_switch.is_on = true
    runtime_switch.save!
  end

end
