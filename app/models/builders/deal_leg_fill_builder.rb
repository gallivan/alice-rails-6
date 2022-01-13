module Builders
  class DealLegFillBuilder

    def self.build(params)
      # puts "DealLegFillBuilder build..."
      # puts params
      system = System.find(params[:system_id])

      if system.code.match 'BKO'
        prng = Random.new
        params[:dealing_venue_done_id] = "BKO-#{prng.rand(1_000_000_000..1_999_999_999)}"
      end

      price, price_traded = self.decode_prices(params[:claim_id], params[:price], params[:price_traded])

      params[:traded_at] = params[:traded_on] if params[:traded_at].blank?

      DealLegFill.new do |f|
        f.kind = 'DATA'
        f.account_id = params[:account_id]
        f.system_id = params[:system_id]
        f.claim_id = params[:claim_id]
        f.done = params[:done]
        f.price = price
        f.price_traded = price_traded
        f.posted_on = params[:posted_on]
        f.traded_on = params[:traded_on]
        f.traded_at = params[:traded_at]
        f.dealing_venue_done_id = params[:dealing_venue_done_id]
        f.dealing_venue_id = params[:dealing_venue_id]
        f.booker_report_id = params[:booker_report_id]
      end
    end

    def self.build_from_ard(params)
      DealLegFill.create! do |f|
        f.kind = 'DATA'
        f.dealing_venue_id = params[:dealing_venue_id]
        f.account_id = params[:account_id]
        f.system_id = System.find_by_code('BKO').id
        f.claim_id = params[:claim_id]
        f.done = params[:done]
        f.price = params[:price]
        f.price_traded = params[:price_traded]
        f.posted_on = params[:posted_on]
        f.traded_on = params[:traded_on]
        f.traded_at = params[:traded_on]
        f.dealing_venue_done_id = params[:dealing_venue_done_id]
        f.booker_report_id = params[:booker_report_id]
      end
    end

    private

    def self.decode_prices(claim_id, price, price_traded)
      claim = Claim.find(claim_id)

      exg, sym = claim.code.split(':')

      if exg =~ /CBT/ and sym =~ /^(S|C|W|KW)/
        price = BigDecimal(price, 16) * 100
        tprx = price.to_f
        head = tprx.floor
        tail = (tprx - head).round(8)
        tail = Claim::CBT_AGG_DEC_TO_FRC_MAP[tail] ||= 'UKN'
        if tail.empty?
          price_traded = head.to_i.to_s
        else
          price_traded = head.to_i.to_s + '-' + tail
        end
      elsif exg =~ /CBT/ and sym =~ /^(17|21|25|26|UBE)/
        price_traded = Claim.cbt_treasury_dec_to_frac(price.to_f)
        price_traded.gsub!(' ', '')
        price_traded.gsub!('-', '') if price_traded.match('-$')
        price_traded.gsub!('\'', '') if price_traded.match('\'$')
      else
        price = BigDecimal(price, 16)
      end
      # puts price
      # puts price_traded

      [price, price_traded]
    end

  end

end
