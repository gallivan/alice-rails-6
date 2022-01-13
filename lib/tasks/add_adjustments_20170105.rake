task :add_adjustments_20170105 => :environment do
  data = {
      '00002' =>  708.36, # -114 + 708.36 = 594.36
      '00005' =>  378.58,
      '00019' =>  537.94,
      '00022' =>  121.99,
      '00024' =>  223.04,
      '00033' =>  323.23,
      '00071' =>  151.60,
      '00077' =>   41.32,
      '00085' =>  229.43,
      '00099' =>   49.97, # -226 + 49.97 = -178.0e
      '00123' =>   86.04,
      '00201' =>  517.56,
      '00333' =>  198.46,
      '00429' =>  367.41,
      '00455' =>  178.57,
      '00624' =>  598.34,
      '00708' =>    6.45,
      '00789' =>  231.98,
      '00877' => 1653.04,
      '00902' => 1396.16,
      '01986' =>    8.30,
      '05520' =>  427.14,
      '39009' =>  954.06,
      '88888' =>   52.34
  }

  date = Date.parse('20170105')
  currency = Currency.find_by_code('EUR')

  #
  # create adjustment for Eurex credits
  #

  data.keys.each do |key|
    account = Account.find_by_code(key)

    Adjustment.transaction do
      begin
        journal_entry = JournalEntry.create! do |e|
          e.journal = Journal.find_by_code('SOLE')
          e.journal_entry_type = JournalEntryType.find_by_code('ADJ')
          e.account = account
          e.currency = currency
          e.posted_on = date
          e.as_of_on = date
          e.amount = data[key]
          e.memo = 'Eurex credits'
          e.segregation = Segregation.find_by_code('SEGN')
        end

        puts "JNL #{journal_entry.account.code} #{journal_entry.posted_on} #{journal_entry.amount} #{journal_entry.currency.code}"

        adjustment = Adjustment.create! do |a|
          a.account = journal_entry.account
          a.adjustment_type = AdjustmentType.find_by_code('MSC')
          a.journal_entry = journal_entry
          a.amount = journal_entry.amount
          a.currency = journal_entry.currency
          a.posted_on = journal_entry.posted_on
          a.memo = journal_entry.memo
          a.segregation = journal_entry.segregation
          a.as_of_on = journal_entry.as_of_on
        end

        puts "ADJ #{adjustment.account.code} #{adjustment.posted_on} #{adjustment.amount} #{adjustment.currency.code}"

      rescue Exception => e
        puts e.message
      end
    end
  end

end
