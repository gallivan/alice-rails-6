task :ghf_setup => :environment do

  map = {
    'LEMMS1' => '00005',
    'LEMMS2' => '00022',
    'LEMMS3' => '00071',
    'LEMMS4' => '00077',
    'LEMMS5' => '00013',
    'LEMMS6' => '00333',
    'LEMMS7' => '00455',
    'LEMMS8' => '00624',
    'LEMMS9' => '00877',
    'LEMMS10' => '00902',
    'LEMMS11' => '02005',
    'LEMMS12' => '02010',
    'LEMMS13' => '01846',
    'LEMMS14' => '05520',
    'LEMMS15' => '55555',
    'LEMMS16' => '06969',
    'LEMMS17' => '88888',
    'LEMMS18' => '39009',
  }

  entity_code = 'GHF'
  system_code = 'GHF MIR13_LON'

  begin
    puts "begun"
    ActiveRecord::Base.transaction do
      puts "setting up Entity"
      Entity.create! { |e|
        e.entity_type = EntityType.find_by_code 'CRP'
        e.code = entity_code
        e.name = 'GH Financials'
      } unless Entity.find_by_code entity_code

      puts "setting up System"
      System.create! { |s|
        s.system_type = SystemType.find_by_code 'BRK'
        s.entity = Entity.find_by_code 'GHF'
        s.code = system_code
        s.name = 'GHF FFastFill MIR13 Transactions File'
      } unless System.find_by_code system_code

      puts "setting up account aliases"
      map.keys.each { |key|
        puts "#{key} #{map[key]}"
        if AccountAlias.where(system_id: System.find_by_code(system_code).id, account_id: Account.find_by_code(map[key]).id).blank?
          puts "creating"
          AccountAlias.create! { |a|
            a.system = System.find_by_code system_code
            a.account = Account.find_by_code map[key]
            a.code = key
          }
        else
          puts "existing"
        end
      }
      puts "ended"
    rescue Exception => e
      puts "Exception: #{e}"
      Rails.logger.warn "Exception: #{e}."
      raise ActiveRecord::Rollback
    end
  end
end