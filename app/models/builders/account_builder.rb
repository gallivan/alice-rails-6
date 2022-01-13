module Builders

  class AccountBuilder

    def self.build(params)
      entity = params[:entity]
      system = params[:system]
      account_code = params[:account_code]

      account = Account.find_by_code(account_code)

      if account.blank?
        account = Account.create! do |a|
          a.account_type_id = AccountType.find_by_code('REG').id
          a.entity_id = entity.id
          a.code = account_code
          a.name = "#{entity.name} #{account_code}"
          a.active = true
        end
      end

      #
      # TODO - use the real alias, e.g., E4444?
      #
      account_alias = AccountAlias.find_by_system_id_and_code(system.id, account_code)

      if account_alias.blank?
        AccountAlias.create! do |a|
          a.account_id = account.id
          a.system_id = system.id
          a.code = account_code
        end
      end

      account
    end

    def self.build_from_cme_eod(params)
      entity = Entity.find_by_code('EMM')
      system = System.find_by_code('CMEsys')
      account_alias_code = params['FIXML']['TrdCaptRpt']['RptSide']['Pty'][4]['ID']

      # remap accounts per email from tim lewis 2020-06-25
      # this could be done with a mapping table - if more to do
      account_alias_code =  '00624' if account_alias_code == '06240'
      account_alias_code =  '00877' if account_alias_code == '08770'

      account = Account.find_by_code(account_alias_code) # for cme

      if account.blank?
        account = Account.create! do |a|
          a.account_type_id = AccountType.find_by_code('REG').id
          a.entity_id = entity.id
          a.code = account_alias_code
          a.name = "#{entity.name} #{account_alias_code}"
          a.active = true
        end
      end

      account_alias = AccountAlias.find_by_system_id_and_code(system.id, account_alias_code)

      if account_alias.blank?
        build({system: system, account_code: account_alias_code, entity: entity})
      end

      account
    end

    def self.build_from_aacc_fix_42_fixml(doc)
      entity = Entity.find_by_code('EMM')
      system = System.find_by_code('AACC')
      account_alias_code = doc.css('FIXML TrdCaptRpt RptSide Pty')[6]['ID']
      account_alias_code = aacc_account_alias_mundger(account_alias_code)
      account_alias = AccountAlias.find_by_system_id_and_code(system.id, account_alias_code)

      if account_alias.blank?
        build({system: system, account_code: account_code, entity: entity})
      else
        account_alias.account
      end
    end

    def self.build_from_aacc_fix_42(params)
      system = params[:system]
      entity = params[:entity]

      account_alias_code = params['1']
      account_alias = AccountAlias.find_by_system_id_and_code(system.id, account_alias_code)

      if account_alias.blank?
        account_code = account_alias_code[-5, 5]
        account_code = aacc_account_alias_mundger(account_code)

        account = Account.find_by_code(account_code)

        account = build({system: system, account_code: account_code, entity: entity}) if account.blank?

        account
      else
        account_alias.account
      end
    end

    def self.build_from_aacc_itd_csv(params)
      entity = params[:entity]
      system = params[:system]
      account_alias_code = params[:ary][2]
      account_alias_code = aacc_account_alias_mundger(account_alias_code)
      account_alias = AccountAlias.find_by_system_id_and_code(system.id, account_alias_code)

      if account_alias.blank?
        account_code = account_alias_code[-5, 5]
        account_code = aacc_account_alias_mundger(account_code)

        account = Account.find_by_code(account_code)

        account = build({system: system, account_code: account_code, entity: entity}) if account.blank?

        account
      else
        account_alias.account
      end
    end

    def self.aacc_account_alias_mundger(code)
      if code =~ /^E4444$/
        code[0] = '4'
      elsif code =~ /^E5555$/
        code[0] = '5'
      elsif code =~ /^E5566$/
        code[0] = '5'
      elsif code =~ /^E6666$/
        code[0] = '6'
      elsif code =~ /^E7777$/
        code[0] = '7'
      elsif code =~ /^E8888$/
        code[0] = '8'
      elsif code =~ /^E9009$/
        code[0] = '3'
      else
        code[0] = '0' if code[0] =~ /E/
      end
      code
    end

  end
end
