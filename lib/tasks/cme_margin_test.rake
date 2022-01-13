require 'xmlsimple'
require 'net/http'
require 'json'

API_KEY = 'API_EMM_DEV'
API_PWD = 'Nuts.Not.Pots'

REQ_ARG = {'Content-Type' => 'application/xml',
           'username' => API_KEY,
           'password' => API_PWD
}

PORTFOLIO = '<?xml version="1.0" encoding="UTF-8"?>
<ns2:transactionReq xmlns:ns2="http://cmegroup.com/schema/core/1.2" reqUserId="ak">
 <transaction portfolioId="{portfolioId}" type="TRADE" id="{transactionId}">
    <payload encoding="STRING" format="CSV">
       <string>
Firm Id,Acct Id,Exchange,Ticker Symbol,Product Name,CC Code,Period Code,Put / Call,Strike,Underlying Period Code,Net Positions,Margin Type
EMM,00375,CBT,,,W,201812,,,,3,FUT
EMM,00375,CBT,,,W,201805,,,,-3,FUT
</string>
    </payload>
 </transaction>
</ns2:transactionReq>'

MARGIN = '<?xml version="1.1" encoding="UTF-8"?>
<core:marginReq xmlns:core="http://cmegroup.com/schema/core/1.2">
  <margin portfolioId="{portfolioId}">
  <amounts ccy="USD" init="0.0" maint="0.0"/>
</margin>
</core:marginReq>'

namespace :cmecore do

  def usage(t, args)
    unless args[:id]
      puts "usage: #{t.name}[id']"
      puts "usage: #{t.name}['1231233']"
      exit
    end
  end

  def rake_setup_post(uri)
    uri = URI(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Post.new(uri.path, REQ_ARG)
    [http, req]
  end

  def rake_setup_get(uri)
    uri = URI(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Get.new(uri.path, REQ_ARG)
    [http, req]
  end

  def rake_setup_del(uri)
    uri = URI(uri)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    req = Net::HTTP::Delete.new(uri.path, REQ_ARG)
    [http, req]
  end

  def next_id
    Time.now.to_i
  end

  def select_portfolio_ids
    ids = []
    begin
      http, req = rake_setup_get('https://cmecorenr.cmegroup.com/MarginServiceApi/portfolios')
      req.body = ''
      res = http.request(req)
      xml_str = res.body
      data = XmlSimple.xml_in xml_str
      data['portfolio'].each {|p| ids << p['id']}
    rescue => e
      puts "failed #{e}"
    end

    puts ids
    ids
  end

  task :select_portfolio_ids do
    select_portfolio_ids
  end

  task :create_portfolio do
    # id = next_id.to_s
    # portfolio = PORTFOLIO.gsub('{portfolioId}', id).gsub('{transactionId}', id)
    # puts portfolio
    portfolio = PORTFOLIO
    puts portfolio
    begin
      http, req = rake_setup_post('https://cmecorenr.cmegroup.com/MarginServiceApi/transactions')
      req.body = portfolio
      res = http.request(req)
      puts res.body
    rescue => e
      puts "failed #{e}"
    end
  end

  task :select_portfolio, [:id] => :environment do |t, args|
    usage(t, args)
    begin
      http, req = rake_setup_get("https://cmecorenr.cmegroup.com/MarginServiceApi/portfolios/#{args[:id]}")
      req.body = ''
      res = http.request(req)
      puts res.body
    rescue => e
      puts "failed #{e}"
    end
  end

  task :select_portfolios do
    begin
      http, req = rake_setup_get('https://cmecorenr.cmegroup.com/MarginServiceApi/portfolios')
      req.body = ''
      res = http.request(req)
      puts res.body
    rescue => e
      puts "failed #{e}"
    end
  end

  task :delete_portfolio, [:id] => :environment do |t, args|
    usage(t, args)
    begin
      http, req = rake_setup_del("https://cmecorenr.cmegroup.com/MarginServiceApi/portfolios/#{args[:id]}")
      req.body = ''
      res = http.request(req)
      puts res.body
    rescue => e
      puts "failed #{e}"
    end
  end

  task :delete_portfolios do
    ids = select_portfolio_ids

    ids.each do |id|
      begin
        puts "deleting portfolio id #{id}"
        http, req = rake_setup_del("https://cmecorenr.cmegroup.com/MarginServiceApi/portfolios/#{id}")
        req.body = ''
        res = http.request(req)
        puts res.body
      rescue => e
        puts "failed #{e}"
      end
    end
  end

  task :create_margin, [:id] do |t, args|
    usage(t, args)
    begin
      http, req = rake_setup_post('https://cmecorenr.cmegroup.com/MarginServiceApi/margins')
      body = MARGIN.gsub('{portfolioId}', args[:id])
      puts body
      req.body = body
      res = http.request(req)
      puts res.body
    rescue => e
      puts "failed #{e}"
    end
  end

  task :select_margin, [:id] do |t, args|
    usage(t, args)
    begin
      url = "https://cmecorenr.cmegroup.com/MarginServiceApi/margins/#{args[:id]}"
      puts url
      http, req = rake_setup_get(url)
      req.body = ''
      res = http.request(req)
      puts res.body
    rescue => e
      puts "failed #{e}"
    end
  end

end