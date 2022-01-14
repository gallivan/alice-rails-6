module Builders

  class ChargeBuilder

    def self.account_claim_date(params)
      account = Account.find(params[:account_id])
      claim = Claim.find(params[:claim_id])
      claim_set = claim.claim_set

      chargeables = []
      chargeables << claim_set.chargeables

      chargeables.flatten!

      # If we have a non-member exchange chargeable and we are a non-member
      # account we want to remove the member chargeable so we apply only one.

      chargeable_type_codes = chargeables.map{|c| c.chargeable_type.code}

      if account.exchange_non_member? and chargeable_type_codes.include? 'ENM'
        chargeables = chargeables.select{|c| c.chargeable_type.code != 'EXG'}
      end

      if not account.exchange_non_member? and chargeable_type_codes.include? 'ENM'
        chargeables = chargeables.select{|c| c.chargeable_type.code != 'ENM'}
      end

      chargeables.each do |chargeable|
        if chargeable.chargeable_type.code =~ /SRV/
          segregation = Segregation.find_by_code('SEGN')
        else
          segregation = Segregation.for_claim(claim)
        end

        chargeable_type = chargeable.chargeable_type

        charge = Charge.create do |f|
          f.account_id = account.id
          f.currency_id = chargeable.currency_id
          f.amount = (chargeable.amount * params[:done]) * -1
          f.posted_on = params[:posted_on]
          f.as_of_on = params[:as_of_on].blank? ? params[:posted_on] : params[:as_of_on]
          f.chargeable_id = chargeable.id
          f.memo = "#{claim.name} #{params[:done].to_i} at #{chargeable.amount} #{f.currency.code} #{chargeable_type.code} "
          f.segregation_id = segregation.id
        end

        journal_entry = JournalEntryBuilder.build_for_charge(charge)
        charge.update({journal_entry_id: journal_entry.id})

        charge
      end
    end

  end
end