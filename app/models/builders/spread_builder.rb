module Builders
  class SpreadBuilder

    def self.build_cqg_spread(params)
      ActiveRecord::Base.transaction do
        leg_claims = params[:leg_claims]

        spread = Spread.create! do |s|
          s.code = params[:code] || leg_claims.pluck(:code).join('-')
          s.name = params[:name] || leg_claims.pluck(:name).join('-')
        end

        leg_claims.each_with_index do |leg_claim, idx|
          SpreadLeg.create! do |l|
            l.spread_id = spread.id
            l.claim_id = leg_claim.id
            l.weight = params[:weights] ? params[:weights][idx] : (idx == 0) ? +1 : -1
          end
        end

        claim_set_code = leg_claims.pluck(:code).map{|x| x.slice(0,x.length-2)}.join('-')
        claim_set_name = leg_claims.pluck(:name).map{|x| x.slice(0,x.length-5)}.join('-')

        claim = Claim.create! do |c|
          c.claim_set = params[:claim_set] || ClaimSet.find_or_create_by(code: claim_set_code, name: claim_set_name)
          c.claim_type = params[:claim_type] || ClaimType.find_or_create_by(code: 'SPD', name: 'Spread')
          c.entity = params[:entity] || leg_claims.first.entity
          c.size = params[:size] || leg_claims.first.size
          c.point_value = params[:point_value] || leg_claims.first.point_value
          c.point_currency = params[:point_currency] || leg_claims.first.point_currency
          c.claimable_id = spread.id
          c.claimable_type = spread.class
          c.code = spread.code
          c.name = spread.name
        end

        spread.update_attribute(:claim, claim)

        spread.claim
      end
    end

  end
end
