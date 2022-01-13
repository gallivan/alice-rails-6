# == Schema Information
#
# Table name: segregations
#
#  id         :integer          not null, primary key
#  code       :string
#  name       :string
#  note       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Segregation < ApplicationRecord

  def self.for_claim(claim)
    self.for_code(claim.code.split(':').first)
  end

  def self.for_position(position)
    self.for_code(position.claim.code.split(':').first)
  end

  def self.for_code(code)
    Segregation.find_by_code('SEGN')

    # if code =~ /(EUREX|LIFFE|MATIF)/
    #   Segregation.find_by_code('SEG7')
    # elsif code =~ /IFEU/
    #   Segregation.find_by_code('SEGD')
    # else
    #   Segregation.find_by_code('SEGN')
    # end

  end

end
