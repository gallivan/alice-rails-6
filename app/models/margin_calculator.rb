# == Schema Information
#
# Table name: margin_calculators
#
#  id         :integer          not null, primary key
#  code       :string           not null
#  name       :string           not null
#  note       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

require 'csv'
require 'xmlsimple'
require 'net/http'
require 'json'
require 'htmlentities'

class MarginCalculator < ApplicationRecord
  validates :code, presence: true
  validates :name, presence: true

  has_many :margins

  ###### api ######

  def calculate_margins_for_date(posted_on)
    EodMailer.status('begun calculating margins').deliver_now
    accounts_to_margin = []
    accounts = Account.active.order(:code)

    accounts.each do |account|
      next if account.reg? and account.positions.open.empty?
      accounts_to_margin << account
    end

    accounts_to_margin.each do |account|
      portfolio = Portfolio.build(account, posted_on)
      margin = submit_portfolio_do(portfolio, posted_on)
      margin = submit_margin_request_do(margin, posted_on)
    end

    accounts_to_margin.each do |account|
      margin = account.portfolios.order(:id).last.margins.order(:id).last
      margin = askfor_margin_do(margin, posted_on)
    end

    accounts_to_margin.each do |account|
      margin = account.portfolios.order(:id).last.margins.order(:id).last
      delete_remote_portfolio(margin) unless margin.blank?
    end
    EodMailer.status('ended calculating margins').deliver_now
  end

  def calculate_margin_for_portfolio(portfolio, posted_on)
    margin = submit_portfolio_do(portfolio, posted_on)
    margin = submit_margin_request_do(margin, posted_on)

    5.times do
      margin = askfor_margin_do(margin, posted_on)
      if margin.margin_requests.order(:id).last.margin_response.success?
        puts 'got a margin result...'
        break
      else
        puts 'sleeping...'
        sleep 60
      end
    end
  end

  def calculate_margin_for_account(account, posted_on)
    portfolio = Portfolio.build(account, posted_on)
    margin_calculator = MarginCalculator.find_by_code 'CME_CORE'
    margin_calculator.calculate_margin_for_portfolio(portfolio, posted_on)
  end

  ###### implementation ######

  def required_arguments
    {'Content-Type' => 'application/xml',
     'username' => RuntimeKnob.code_for_name('cme_core_api_key'),
     'password' => RuntimeKnob.code_for_name('cme_core_api_pwd')
    }
  end

  def submit_portfolio_do(portfolio, posted_on)
    submit_portfolio(Margin.build(portfolio, posted_on), posted_on)
  end

  def submit_margin_request_do(margin, posted_on)
    submit_margin_request(margin, posted_on)
  end

  def askfor_margin_do(margin, posted_on)
    askfor_margin(margin, posted_on)
  end

  #
  # need to do a better job of delete
  # need to do a better job of delete
  # need to do a better job of delete
  # need to do a better job of delete
  #

  def setup_del(uri)
    uri = URI(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Delete.new(uri.path, required_arguments)
    [http, req]
  end

  def delete_remote_portfolio(margin)
    remote_portfolio_id = margin.remote_portfolio_id
    begin
      puts "deleting portfolio id #{remote_portfolio_id}"
      uri_root = RuntimeKnob.code_for_name('cme_core_api_root')
      http, req = setup_del("https://#{uri_root}/MarginServiceApi/portfolios/#{remote_portfolio_id}")
      req.body = ''
      res = http.request(req)
      puts res.body
    rescue => e
      puts "failed #{e}"
    end
  end

  def submit_portfolio(margin, posted_on)
    portfolio = margin.portfolio

    lines = portfolio_to_cvs(portfolio)
    req_xml = cme_transactions_xml_stub(portfolio.account.id, portfolio.account.id, lines)

    margin_request = MarginRequest.build(margin, posted_on)
    margin_request.update(:body, req_xml)
    margin_response = MarginResponse.build(margin_request, posted_on)
    margin_request.update(:margin_response, margin_response)

    begin
      uri_root = RuntimeKnob.code_for_name('cme_core_api_root')
      http, req = setup_post("https://#{uri_root}/MarginServiceApi/transactions")
      req.body = req_xml
      res = http.request(req)
      res_xml = margin_response_body_cleanp(res.body)

      doc = Nokogiri::XML(res_xml)
      portfolio_id = doc.xpath('//transaction/@portfolioId').first.value

      margin.update(:remote_portfolio_id, portfolio_id)
      margin.update(:margin_status, MarginStatus.find_by_code('OPEN'))
      margin_request.update(:margin_request_status, MarginRequestStatus.find_by_code('DONE'))
      margin_response.update(:body, res_xml)
      margin_response.update(:margin_response_status, MarginResponseStatus.find_by_code('DONE'))
    rescue => e
      msg = "MarginRequest for #{margin.id} failed #{e}"
      Rails.logger.warn msg
      margin.update(:margin_status, MarginStatus.find_by_code('FAIL'))
      margin_request.update(:fail, msg)
      margin_request.update(:margin_request_status, MarginRequestStatus.find_by_code('FAIL'))
      margin_response.update(:body, res_xml)
      margin_response.update(:margin_response_status, MarginResponseStatus.find_by_code('FAIL'))
    end

    margin
  end

  def submit_margin_request(margin, posted_on)
    puts "using report_portfolio_id #{margin.remote_portfolio_id}"

    req_xml = cme_margin_request_xml_stub(margin.remote_portfolio_id)

    margin_request = MarginRequest.build(margin, posted_on)
    margin_request.update(:body, req_xml)
    margin_response = MarginResponse.build(margin_request, posted_on)
    margin_request.update(:margin_response, margin_response)

    begin
      uri_root = RuntimeKnob.code_for_name('cme_core_api_root')
      http, req = setup_post("https://#{uri_root}/MarginServiceApi/margins")
      res = http.request(req)
      req.body = req_xml
      res = http.request(req)
      res_xml = res.body

      doc = Nokogiri::XML(res_xml)
      margin_id = doc.xpath('//margin/@id').first.value

      margin.update(:remote_margin_id, margin_id)
      margin.update(:margin_status, MarginStatus.find_by_code('SENT'))
      margin_request.update(:margin_request_status, MarginRequestStatus.find_by_code('DONE'))
      margin_response.update(:body, res_xml)
      margin_response.update(:margin_request_status, MarginRequestStatus.find_by_code('DONE'))
    rescue => e
      msg = "MarginRequest for #{margin.id} failed #{e}"
      Rails.logger.warn msg
      margin.update(:margin_status, MarginStatus.find_by_code('FAIL'))
      margin_request.update(:fail, msg)
      margin_request.update(:margin_request_status, MarginRequestStatus.find_by_code('FAIL'))
      margin_response.update(:body, res_xml)
      margin_response.update(:margin_response_status, MarginResponseStatus.find_by_code('FAIL'))
    end

    margin
  end

  def askfor_margin(margin, posted_on)
    puts "using report_portfolio_id #{margin.remote_portfolio_id}"

    margin_request = MarginRequest.build(margin, posted_on)
    margin_response = MarginResponse.build(margin_request, posted_on)
    margin_request.update(:margin_response, margin_response)

    begin
      uri_root = RuntimeKnob.code_for_name('cme_core_api_root')
      margin_request.update(:body, "https://#{uri_root}/MarginServiceApi/margins/#{margin.remote_margin_id}")

      http, req = setup_get(margin_request.body)
      res = http.request(req)
      res_xml = res.body

      doc = Nokogiri::XML(res_xml)

      margin_response.update(:body, res_xml)

      if doc.xpath('//amounts/@init').first.value.blank?
        margin.update(:margin_status, MarginStatus.find_by_code('WORK'))
        margin_request.update(:margin_request_status, MarginRequestStatus.find_by_code('DONE'))
        margin_response.update(:margin_response_status, MarginResponseStatus.find_by_code('DONE'))
      else
        initial = doc.xpath('//amounts/@init').first.value
        maintenance = doc.xpath('//amounts/@maint').first.value

        margin.update(:initial, initial)
        margin.update(:maintenance, maintenance)
        margin.update(:margin_status, MarginStatus.find_by_code('DONE'))
        margin_request.update(:margin_request_status, MarginRequestStatus.find_by_code('DONE'))
        margin_response.update(:body, res_xml)
        margin_response.update(:margin_response_status, MarginResponseStatus.find_by_code('DONE'))
      end
    rescue => e
      msg = "MarginRequest for #{margin.id} failed #{e}"
      Rails.logger.warn msg

      margin.update(:margin_status, MarginStatus.find_by_code('FAIL'))
      margin_request.update(:fail, msg)
      margin_request.update(:margin_request_status, MarginRequestStatus.find_by_code('FAIL'))
      margin_response.update(:body, res_xml)
      margin_response.update(:margin_response_status, MarginResponseStatus.find_by_code('FAIL'))
    end

    margin
  end

  def cme_transactions_xml_stub(portfolio_id, transaction_id, lines)
    <<-HEREDOC
<?xml version="1.0" encoding="UTF-8"?>
<ns2:transactionReq xmlns:ns2="http://cmegroup.com/schema/core/1.2" reqUserId="ak">
<transaction portfolioId="#{portfolio_id}" type="TRADE" id="#{transaction_id}">
<payload encoding="STRING" format="CSV">
<string>
Firm Id,Acct Id,Exchange,Ticker Symbol,Product Name,CC Code,Period Code,Put / Call,Strike,Underlying Period Code,Net Positions,Margin Type
#{lines}
</string>
</payload>
</transaction>
</ns2:transactionReq>
    HEREDOC
  end

  def cme_margin_request_xml_stub(portfolio_id)
    <<-HEREDOC
<?xml version="1.1" encoding="UTF-8"?>
<core:marginReq xmlns:core="http://cmegroup.com/schema/core/1.2">
<margin portfolioId="#{portfolio_id}">
<amounts ccy="USD" conc="0.0" init="0.0" maint="0.0" nonOptVal="0.0" optVal="0.0"/>
</margin>
</core:marginReq>
    HEREDOC
  end

  def position_to_cme(position, account_code)
    # TED,1234,CME,,,ED,201906,,,,100,FUT
    # TED,1234,CME,,,ED,201909,,,,100,FUT
    # TED,1234,CME,,,ED,201912,,,,100,FUT
    # TED,1234,CME,,,ED,202003,,,,100,FUT

    exchange_code, claim_set_code = position.claim.claim_set.code.split(':')

    line = []
    line << 'EMM'
    line << account_code
    line << exchange_code
    line << nil
    line << nil
    line << claim_set_code
    line << position.claim.expires_on.strftime('%Y%m')
    line << nil
    line << nil
    line << nil
    line << position.net.to_i
    line << position.claim.claim_type.code

    line
  end

  def setup_post(uri)
    uri = URI(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Post.new(uri.path, required_arguments)
    [http, req]
  end

  def setup_get(uri)
    uri = URI(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Get.new(uri.path, required_arguments)
    [http, req]
  end

  def margin_response_body_cleanp(body)
    xml = HTMLEntities.new.decode(body)
    xml.gsub!('<?xml version="1.0" encoding="UTF-8" standalone="yes"?>', '')
    xml.gsub!('ns2:', '')
    xml
  end

  def portfolio_to_cvs(portfolio)
    account_code = portfolio.account.code
    lines = CSV.generate do |csv|
      portfolio.positions.each do |position|
        csv << position_to_cme(position, account_code)
      end
      puts lines
      lines
    end
  end

end
