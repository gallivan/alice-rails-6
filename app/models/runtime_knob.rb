# == Schema Information
#
# Table name: runtime_knobs
#
#  id         :integer          not null, primary key
#  name       :string
#  code       :string
#  note       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class RuntimeKnob < ApplicationRecord
  validates :name, presence: true #, inclusion: {in: ['settlement_price_source']}
  validates :code, presence: true #, inclusion: {in: ['EMM', 'QDL']}
  validates :note, presence: true

  def self.all_found?
    search = [
        :cme_core_api_key,
        :cme_core_api_pwd,
        :cme_core_api_root,
        :quandl_sleep_time,
        :settlement_price_source,
    ]

    found = RuntimeKnob.all.pluck(:name).map {|name| name.to_sym}.sort

    if (search - found).empty?
      true
    else
      msg = "RuntimeKnob missing: #{search - found}."
      Rails.logger.warn msg
      EodMailer.alert(msg).deliver_now
      false
    end
  end

  def self.code_for_name(name)
    knob = find_by_name(name)
    (knob.blank?) ? knob : knob.code
  end

end
