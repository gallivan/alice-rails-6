# == Schema Information
#
# Table name: claims
#
#  id                :integer          not null, primary key
#  claim_set_id      :integer          not null
#  claim_type_id     :integer          not null
#  entity_id         :integer
#  claimable_id      :integer          not null
#  claimable_type    :string           not null
#  code              :string           not null
#  name              :string           not null
#  size              :decimal(, )      default(1.0), not null
#  point_value       :decimal(, )      default(1.0), not null
#  point_currency_id :integer          not null
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#

class Claim < ApplicationRecord
  validates :claim_type, presence: true
  validates :claim_set, presence: true
  validates :entity, presence: true
  validates :claimable, presence: true
  validates :claimable_type, presence: true
  validates :code, presence: true
  validates :name, presence: true
  validates :size, presence: true
  validates :point_value, presence: true
  validates :point_currency, presence: true

  has_many :deal_legs
  has_many :deal_leg_fills
  has_many :positions
  has_many :position_nettings
  has_many :claim_marks
  has_many :claim_aliases

  belongs_to :claim_type
  belongs_to :claim_set
  belongs_to :entity

  belongs_to :point_currency, class_name: 'Currency'

  # http://6ftdan.com/allyourdev/2015/02/10/rails-polymorphic-models/
  belongs_to :claimable, :polymorphic => true

  scope :monies, -> { where(claimable_type: 'Money') }
  scope :futures, -> { where(claimable_type: 'Future') }
  scope :spreads, -> { where(claimable_type: 'Spread') }

  CBT_FRC_TO_DEC_MAP = {
      0.1 => 0.125,
      0.2 => 0.250,
      0.3 => 0.375,
      0.5 => 0.500,
      0.6 => 0.625,
      0.7 => 0.750,
      0.8 => 0.875
  }

  CBT_FRC_TO_DEC_MAP_2 = {
      '1' => 0.00125,
      '2' => 0.00250,
      '3' => 0.00375,
      '5' => 0.00500,
      '6' => 0.00625,
      '7' => 0.00750,
      '8' => 0.00875
  }

  CBT_AGG_DEC_TO_FRC_MAP = {
      0.0 => '',
      0.125 => '1/8',
      0.25 => '1/4',
      0.375 => '3/8',
      0.50 => '1/2',
      0.625 => '5/8',
      0.75 => '3/4',
      0.875 => '7/8'
  }


  # CME HAS INTRODUCED 1/4 of 1/32 ticks.
  TEST_MAP = {
      0.0 => '000',
      0.0078125 => '002', # 1/4 of 1/32
      0.015625 => '005', # 1/2 of 1/32
      0.0234375 => '007', # 3/4 of 1/32
      0.03125 => '010' # 1/32
  }

  CBT_INT_DEC_TO_FRC_MAP = {
      0.0 => '000',
      0.0078125 => '002',
      0.015625 => '005',
      0.0234375 => '007',
      0.03125 => '010',
      0.0390625 => '012',
      0.046875 => '015',
      0.0546875 => '017',
      0.0625 => '020',
      0.0703125 => '022',
      0.078125 => '025',
      0.0859375 => '027',
      0.09375 => '030',
      0.1015625 => '032',
      0.109375 => '035',
      0.1171875 => '037',
      0.125 => '040',
      0.1328125 => '042',
      0.140625 => '045',
      0.1484375 => '047',
      0.15625 => '050',
      0.1640625 => '052',
      0.171875 => '055',
      0.1796875 => '057',
      0.1875 => '060',
      0.1953125 => '062',
      0.203125 => '065',
      0.2109375 => '067',
      0.21875 => '070',
      0.2265625 => '072',
      0.234375 => '075',
      0.2421875 => '077',
      0.25 => '080',
      0.2578125 => '082',
      0.265625 => '085',
      0.2734375 => '087',
      0.28125 => '090',
      0.2890625 => '092',
      0.296875 => '095',
      0.3046875 => '097',
      0.3125 => '100',
      0.3203125 => '102',
      0.328125 => '105',
      0.3359375 => '107',
      0.34375 => '110',
      0.3515625 => '112',
      0.359375 => '115',
      0.3671875 => '117',
      0.375 => '120',
      0.3828125 => '122',
      0.390625 => '125',
      0.3984375 => '127',
      0.40625 => '130',
      0.4140625 => '132',
      0.421875 => '135',
      0.4296875 => '137',
      0.4375 => '140',
      0.4453125 => '142',
      0.453125 => '145',
      0.4609375 => '147',
      0.46875 => '150',
      0.4765625 => '152',
      0.484375 => '155',
      0.4921875 => '157',
      0.5 => '160',
      0.5078125 => '162',
      0.515625 => '165',
      0.5234375 => '167',
      0.53125 => '170',
      0.5390625 => '172',
      0.546875 => '175',
      0.5546875 => '177',
      0.5625 => '180',
      0.5703125 => '182',
      0.578125 => '185',
      0.5859375 => '187',
      0.59375 => '190',
      0.6015625 => '192',
      0.609375 => '195',
      0.6171875 => '197',
      0.625 => '200',
      0.6328125 => '202',
      0.640625 => '205',
      0.6484375 => '207',
      0.65625 => '210',
      0.6640625 => '212',
      0.671875 => '215',
      0.6796875 => '217',
      0.6875 => '220',
      0.6953125 => '222',
      0.703125 => '225',
      0.7109375 => '227',
      0.71875 => '230',
      0.7265625 => '232',
      0.734375 => '235',
      0.7421875 => '237',
      0.75 => '240',
      0.7578125 => '242',
      0.765625 => '245',
      0.7734375 => '247',
      0.78125 => '250',
      0.7890625 => '252',
      0.796875 => '255',
      0.8046875 => '257',
      0.8125 => '260',
      0.8203125 => '262',
      0.828125 => '265',
      0.8359375 => '267',
      0.84375 => '270',
      0.8515625 => '272',
      0.859375 => '275',
      0.8671875 => '277',
      0.875 => '280',
      0.8828125 => '282',
      0.890625 => '285',
      0.8984375 => '287',
      0.90625 => '290',
      0.9140625 => '292',
      0.921875 => '295',
      0.9296875 => '297',
      0.9375 => '300',
      0.9453125 => '302',
      0.953125 => '305',
      0.9609375 => '307',
      0.96875 => '310',
      0.9765625 => '312',
      0.984375 => '315',
      0.9921875 => '317'
  }

  def self.cbt_treasury_dec_to_frac(price)
    #
    # https://www.cmegroup.com/confluence/display/EPICSANDBOX/Fractional+Pricing+-+Display+Factor+Examples
    #
    tail = price - price.to_i
    head = (price - tail).to_i
    tail = CBT_INT_DEC_TO_FRC_MAP[tail]
    if tail.blank?
      "#{price}"
    else
      "#{head}'#{tail}"
    end
  end

  def to_s
    self.name
  end

  def self.select_options
    select("id, name").order(:code).all.collect { |a| [" #{a.name}", a.id] }
  end

  def self.spread_set_select_options
    spreads.joins(:claim_set).distinct.order('claim_sets.code').pluck('claim_sets.code, claim_sets.id')
  end

  def self.spread_select_options
    spreads.order(:code).pluck(:code, :id)
  end

  def mark(params)
    post_claim_mark(params)
  end

  def post_claim_mark(params)
    ClaimMark.create! do |s|
      s.system_id = params[:system_id]
      s.claim_id = self.id
      s.posted_on = params[:posted_on]
      s.mark = params[:mark]
      s.approved = params[:approved]
    end
  end

  def expires_on
    claimable.expires_on
  end

  def expired?
    Date.today > expires_on
  end

  # <?xml version="1.0" encoding="UTF-8" standalone="no"?>
  # <CALENDAR_DATA>
  #   <DATE_CREATED>12/23/2016 20:00:38</DATE_CREATED>
  #   <PRODUCT_TYPES>
  #     <PRODUCT_TYPE>AGRICULTURAL</PRODUCT_TYPE>
  #     <PRODUCT>
  #       <Exchange>XCBT</Exchange>
  #       <Commodity_Name>SOYBEAN MEAL</Commodity_Name>
  #       <Commodity_Code>06</Commodity_Code>
  #       <PRODUCT_TYPE_CODE>FUT</PRODUCT_TYPE_CODE>
  #       <CONTRACT>
  #         <Contract_Name>December  2016  Soybean Meal Futures</Contract_Name>
  #         <Contract_Product_Code>201612</Contract_Product_Code>
  #         <Exp_Contract_Code>06Z16</Exp_Contract_Code>
  #         <ITC_Code>ZM</ITC_Code>
  #         <Contract_Code>06Z6</Contract_Code>
  #         <FTD>12/17/2012</FTD>
  #         <LTD>12/14/2016</LTD>
  #         <SD>12/14/2016</SD>
  #         <DD>12/23/2016</DD>
  #         <IID>11/25/2016</IID>
  #         <FID>11/29/2016</FID>
  #         <FND>11/30/2016</FND>
  #         <FDD>12/01/2016</FDD>
  #         <LPD>12/15/2016</LPD>
  #         <LID>12/15/2016</LID>
  #         <LND>12/15/2016</LND>
  #         <LDD>12/16/2016</LDD>
  #       </CONTRACT>
  #         ...
  #       <CONTRACT>
  #       </CONTRACT>
  #     </PRODUCT>
  #     <PRODUCT>
  #     </PRODUCT>
  #   </PRODUCT_TYPE>
  #     <PRODUCT_TYPE>SOFT</PRODUCT_TYPE>
  #     <PRODUCT>
  #     </PRODUCT>
  #       ...
  #     <PRODUCT>
  #     </PRODUCT>
  #   </PRODUCT_TYPES>
  # </CALENDAR_DATA>
  #
  def self.update_cme_contract_names()
    EodMailer.status('begun updating CME names').deliver_now

    require 'xmlsimple'

    picker = Workers::PickerOfEodCme.new
    picker.get_product_calendar_file

    todo = {}
    done = 0
    Claim.pluck(:id, :code).each { |element| todo[element.last] = element.first }

    puts "#{todo.keys.count} to do"

    hash = XmlSimple.xml_in("#{ENV['DNL_DIR']}/spn/product_calendar.xml", {'KeyAttr' => 'name'})

    hash['PRODUCT_TYPES'].each do |product_type|
      # puts '*' * 20
      # puts product_type['PRODUCT_TYPE'] # e.g. AGRICULTURAL
      product_type['PRODUCT'].each do |product|
        # puts product['Exchange'] # e.g. XCBT
        # puts product['Commodity_Name'] # e.g. SOYBEAN MEAL
        # puts product['Commodity_Code'] # e.g. 06
        # puts product['PRODUCT_TYPE_CODE'] # e.g. FUT
        if product['PRODUCT_TYPE_CODE'].first == 'FUT'
          product['CONTRACT'].each do |contract|
            if product['Exchange'].first.reverse.chop.reverse == 'NYM'
              # TODO this condition suggests i should refactor to use NYM
              code = "NYMEX:#{contract['Exp_Contract_Code'].first}"
            else
              code = "#{product['Exchange'].first.reverse.chop.reverse}:#{contract['Exp_Contract_Code'].first}"
            end
            if todo[code]
              self.update_cme_claim(todo[code], contract, product_type['PRODUCT_TYPE'].first)
              done += 1
            end
          end
        end
      end
    end
    EodMailer.status('ended updating CME names').deliver_now
  end


  #
  # missing FID
  #
  # CBT:25H17
  # {"Contract_Name"=>["March  2017  5-Year T-Note Options"], "Contract_Product_Code"=>["201703"], "Exp_Contract_Code"=>["25H17"], "Contract_Code"=>["25H7"], "Option_Type"=>["AME"], "FTD"=>["07/01/2016"], "LTD"=>["02/24/2017"], "SD"=>["02/24/2017"], "DD"=>["03/03/2017"]}
  # CME:EDZ18
  # {"Contract_Name"=>["March  2019  Eurodollar Options"], "Contract_Product_Code"=>["201903"], "Exp_Contract_Code"=>["EDH19"], "Contract_Code"=>["EDH9"], "Option_Type"=>["AME"], "FTD"=>["03/16/2015"], "LTD"=>["03/18/2019"], "SD"=>["03/18/2019"], "DD"=>["03/25/2019"]}

  def self.update_cme_claim(id, contract, sector)
    claim = Claim.find id

    if contract['Contract_Name'].first
      # move month and year from front to back
      name = contract['Contract_Name'].first
      name = name.split.rotate.rotate.join(' ')
      claim.update(:name, name)
    end

    claim_set = claim.claim_set
    claim_set.update(:sector, sector)

    claimable = claim.claimable

    parse_cme_date = ->(str) {
      m, d, y = str.split('/')
      input = "#{y}-#{m}-#{d}"
      Date.parse(input)
    }

    claimable.update(:first_intent_on, parse_cme_date.call(contract['FID'].first)) unless contract['FID'].blank?
    claimable.update(:last_intent_on, parse_cme_date.call(contract['LID'].first)) unless contract['LID'].blank?

    claimable.update_attribute(:first_delivery_on, parse_cme_date.call(contract['FDD'].first)) unless contract['FDD'].blank?
    claimable.update_attribute(:last_delivery_on, parse_cme_date.call(contract['LDD'].first)) unless contract['LDD'].blank?

    claimable.update_attribute(:last_trade_on, parse_cme_date.call(contract['LTD'].first)) unless contract['LTD'].blank?
  end

end
