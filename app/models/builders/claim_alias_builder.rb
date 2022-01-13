module Builders

  class ClaimAliasBuilder

    def self.build_for_acc(params)
      system = System.find_by_code(params['49'])
      exchange_code = params['9039'].slice(71, 5)
      claim_code = params['55']
      maturity_date = params['200']
      ClaimAlias.create! do |a|
        a.claim = claim
        a.system = system
        a.code = "#{exchange_code}:#{claim_code}:#{maturity_date}"
      end
    end
  end
end
