require 'quandl'

module Workers
  class QuandlDAO

    def self.quandl_code_for_claim(claim)
      system = System.where(code: 'QDL').first
      claim_set = claim.claim_set
      claim_set_alias = (ClaimSetAlias.where claim_set_id: claim_set.id, system_id: system.id).first

      while claim_set_alias.blank?
        msg = "#{system.name} ClaimSetAlias missing for #{claim.code}."
        Rails.logger.warn msg
        EodMailer.alert(msg).deliver_now
        Rails.logger.warn "Sleeping until #{15.minutes.from_now}."
        sleep 900
        claim_set_alias = (ClaimSetAlias.where claim_set_id: claim_set.id, system_id: system.id).first
      end

      claim_set_alias.code + claim.code[-3] + '20' + claim.code[-2..-1]
    end

    def self.get_quandl_marks(date, claims)
      Rails.logger.info 'Getting Quandl marks'
      puts "Checking for #{claims.size} marks."
      claims.each do |claim|
        get_quandl_mark(date, claim)
      end
    end

    def self.get_quandl_mark(date, claim)
      Quandl::ApiConfig.api_key = ENV['QUANDL_API_KEY']
      Quandl::ApiConfig.api_version = '2015-04-09'

      if Quandl::ApiConfig.api_key.blank?
        Rails.logger.warn "Quandl api key not set. Exiting."
        return
      end

      # curl "https://data.nasdaq.com/api/v3/datasets/EUREX/FDAXM2016/data.csv?start_date=2016-03-30&end_date=2016-03-30&api_key=g-d7xhAs-eJsXPeJkinZ" -X GET

      q_code = quandl_code_for_claim(claim)

      claim_mark = ClaimMark.posted_on(date).posted_for(claim.id).first

      if claim_mark.blank?
        Rails.logger.info "Seek: code #{claim.code} key #{q_code}"
        try_quandl(claim, q_code, date)
      else
        msg = "Skip: code #{claim.code} key #{q_code} settled #{claim_mark.mark}"
        puts msg
        Rails.logger.info msg
      end
    end

    def self.try_quandl(claim, key, date)
      Rails.logger.info '*' * 80
      #
      # https://data.nasdaq.com/data/CME/SX2019-Soybean-Futures-November-2019-SX2019
      # https://data.nasdaq.com/data/CME/EDU2019-Eurodollar-Futures-September-2019-EDU2019
      # https://data.nasdaq.com/data/CME/USU2019-U-S-Treasury-Bond-Futures-September-2019-USU2019
      #
      # json = `curl "https://data.nasdaq.com/api/v3/datasets/CME/BOV2016.json?start_date=2016-10-11&end_date=2016-10-11&rows=1&api_key=g-d7xhAs-eJsXPeJkinZ"`
      # json = `curl "https://data.nasdaq.com/api/v3/datasets/EUREX/FESXZ2016.json?start_date=2016-10-10&end_date=2016-10-10&rows=1&api_key=g-d7xhAs-eJsXPeJkinZ"`
      # hash = JSON.parse(json)
      # setl = hash['dataset']['data'][0][6]

      date_str = date.strftime('%Y-%m-%d')

      begin
        # json = `curl "https://data.nasdaq.com/api/v3/datasets/#{key}.json?start_date=#{date_str}&end_date=#{date_str}&rows=1&api_key=g-d7xhAs-eJsXPeJkinZ"`

        query = "https://data.nasdaq.com/api/v3/datasets/#{key}.json?start_date=#{date_str}&end_date=#{date_str}&rows=1&api_key=g-d7xhAs-eJsXPeJkinZ"
        Rails.logger.info "Quandl Query: #{query}"

        json = RestClient.get query
        Rails.logger.info 'JSON ' * 5
        Rails.logger.info json

        hash = JSON.parse(json)
        Rails.logger.info 'HASH ' * 5
        Rails.logger.info hash

        if hash['dataset'].blank? or hash['dataset']['data'].blank?

          # check this blankness

          Rails.logger.info "Miss: code #{claim.code} key #{key}"
          msg = "Quandl Service has no data for code #{claim.code} key #{key} on date #{date}"
          EodMailer.alert(msg).deliver_now
          Rails.logger.warn msg
        else
          price = nil
          index = nil

          if hash['dataset']['column_names'].include?('Settle')
            index = hash['dataset']['column_names'].index('Settle')
          elsif hash['dataset']['column_names'].include?('Close')
            index = hash['dataset']['column_names'].index('Close')
          elsif hash['dataset']['column_names'].include?('Last')
            index = hash['dataset']['column_names'].index('Last')
          else
            raise "Location of settlement or closing price not found."
          end

          mark = BigDecimal(hash['dataset']['data'][0][index], 16)

          Rails.logger.info "Grab: code #{claim.code} key #{key} settle #{price}."

          begin
            ClaimMark.create! do |s|
              s.system_id = System.find_by_code('QDL').id
              s.claim_id = claim.id
              s.posted_on = date
              s.mark = mark
              s.approved = false
            end
          rescue Exception => e
            Rails.logger.warn e.message
            Rails.logger.warn "Exception at #{Time.now}."
          end
        end
      rescue Exception => e
        msg = "Quandl Service Exception: #{e.message}"
        url = "https://data.nasdaq.com/data/#{key}"
        EodMailer.alert(msg).deliver_now
        Rails.logger.warn "#{msg} (see page #{url})"
      end
    end

    def self.backfill_prices_and_volumes(period_bagun_on, period_ended_on)

      begun_on_str = period_bagun_on.strftime('%Y-%m-%d')
      ended_on_str = period_ended_on.strftime('%Y-%m-%d')

      Claim.all.each do |claim|
        system = System.find_by_code 'QDL'
        q_code = quandl_code_for_claim(claim)
        puts claim.code
        Rails.logger.info "Backfilling prices and volumes for #{claim.code}"
        query = "https://data.nasdaq.com/api/v3/datasets/#{q_code}.json?start_date=#{begun_on_str}&end_date=#{ended_on_str}&api_key=g-d7xhAs-eJsXPeJkinZ"
        hash = try_quandl_query(query)
        hash['dataset']['data'].each do |data|
          puts '*' * 20
          Rails.logger.info data
          Rails.logger.info claim.code
          Rails.logger.info data
          Rails.logger.info 'A' * 20
          params = {
              system: system,
              claim: claim,
              approved: false
          }
          Rails.logger.info 'B' * 20

          # ["Date", "Open", "High", "Low",                   "Settle", "Volume", "Interest"]
          # ["Date", "Open", "High", "Low", "Last", "Change", "Settle", "Volume",            "Previous Day Open Interest"]
          # ["Date", "Open", "High", "Low",                   "Close",  "Volume",            "Prev Day OI",               "Prev Day Volume"]

          index_date = hash['dataset']['column_names'].index('Date')
          index_open = hash['dataset']['column_names'].index('Open')
          index_high = hash['dataset']['column_names'].index('High')
          index_low = hash['dataset']['column_names'].index('Low')
          index_last = hash['dataset']['column_names'].index('Last')
          index_change = hash['dataset']['column_names'].index('Change')
          index_volume = hash['dataset']['column_names'].index('Volume')
          index_interest = hash['dataset']['column_names'].index('Interest')
          # index_interest_previous = hash['dataset']['column_names'].index('Previous Day Open Interest')

          if hash['dataset']['column_names'].include?('Settle')
            index_settle = hash['dataset']['column_names'].index('Settle')
          elsif hash['dataset']['column_names'].include?('Close')
            index_settle = hash['dataset']['column_names'].index('Close')
          else
            raise "Location of settlement or closing price not found."
          end

          date = Date.parse(data[index_date])
          open = BigDecimal(data[index_open].to_f, 16)
          high = BigDecimal(data[index_high].to_f, 16)
          low = BigDecimal(data[index_low].to_f, 16)
          last = BigDecimal(data[index_last].to_f, 16)
          mark = BigDecimal(data[index_settle].to_f, 16)
          volume = BigDecimal(data[index_volume].to_f, 16)
          change = data[index_change].blank? ? nil : BigDecimal(data[index_change].to_f, 16)
          interest = data[index_interest].blank? ? nil : BigDecimal(data[index_interest].to_f, 16)

          params.merge!(
              {
                  posted_on: date,
                  open: open,
                  high: high,
                  low: low,
                  mark: mark,
                  volume: volume,
              }
          )

          Rails.logger.info 'C' * 20
          if params[:mark].blank?
            Rails.logger.warn "Mark blank for #{claim.code} on #{params[:posted_on]}. Skipping."
            next
          end
          Rails.logger.info 'D' * 20
          claim_mark = ClaimMark.where(claim_id: claim.id, system_id: system.id, posted_on: params[:posted_on]).first
          claim_mark.destroy unless claim_mark.blank?
          ClaimMark.create! params
        end
      end
    end

    def self.try_quandl_query(query)
      begin
        Rails.logger.info "Quandl Query: #{query}"
        json = RestClient.get query
        Rails.logger.info json
        JSON.parse(json)
      rescue Exception => e
        msg = "Quandl Service Exception: #{e.message}"
        EodMailer.alert(msg).deliver_now
        Rails.logger.warn msg
        Rails.logger.warn "Exception at #{Time.now}."
        Rails.logger.warn "Retrying in 5 minutes."
        sleep 5.minutes
        retry
      end
    end

    def self.get_claim_name(claim)
      code = self.quandl_code_for_claim(claim)
      begin
        msg = "Getting name given #{claim.code}[#{code}]."
        puts msg
        Rails.logger.info msg

        claim_mark = claim.claim_marks.order(:id).last

        date = claim_mark.blank? ? claim.claimable.expires_on : claim_mark.posted_on
        date_str = date.strftime('%Y-%m-%d')

        query = "https://data.nasdaq.com/api/v3/datasets/#{code}.json?start_date=#{date_str}&end_date=#{date_str}&rows=1&api_key=g-d7xhAs-eJsXPeJkinZ"
        json = RestClient.get query

        data = JSON.parse(json)
        data['dataset']['name']
      rescue Exception => e
        Rails.logger.warn "Quandl Service Exception: #{e.message}"
        Rails.logger.warn "Retrying in 5 seconds"
        sleep 5
        retry
      end
    end

    def self.fx_rates
      # TODO use env
      api_key = '?&api_key=g-d7xhAs-eJsXPeJkinZ'
      hash = {
          "CHF" => "http://data.nasdaq.com/api/v3/datasets/BOE/XUDLSFD.json#{api_key}",
          "DKK" => "http://data.nasdaq.com/api/v3/datasets/BOE/XUDLDKD.json#{api_key}",
          "EUR" => "http://data.nasdaq.com/api/v3/datasets/ECB/EURUSD.json#{api_key}",
          "GBP" => "http://data.nasdaq.com/api/v3/datasets/BOE/XUDLGBD.json#{api_key}",
          "JPY" => "http://data.nasdaq.com/api/v3/datasets/BOE/XUDLJYD.json#{api_key}",
          "NOK" => "http://data.nasdaq.com/api/v3/datasets/BOE/XUDLNKD.json#{api_key}",
          "SEK" => "http://data.nasdaq.com/api/v3/datasets/BOE/XUDLSKD.json#{api_key}"
      }

      out = {}

      begin
        hash.keys.each do |key|
          query = hash[key]
          json = RestClient.get query
          data = JSON.parse(json)
          rate = data['dataset']['data'].first.last
          unless key.match(/EUR|CHF/)
            rate = (1/rate).round(6)
          end
          out[key] = rate
        end
        out['USD'] = 1.0
      rescue Exception => e
        Rails.logger.warn "Quandl Service Exception: #{e.message}"
        Rails.logger.warn "Retrying in 5 seconds"
        sleep 5
        retry
      end

      out
    end

  end #Quandl
end # Workers
