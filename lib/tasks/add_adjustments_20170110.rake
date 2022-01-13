task :add_adjustments_20170110 => :environment do

  data = <<HERE
00002:CBT/CME DEC 2016 Rebate CBT:2657.40
00005:CBT/CME DEC 2016 Rebate CBT:2768.70
00019:CBT/CME DEC 2016 Rebate CBT: 942.60
00022:CBT/CME DEC 2016 Rebate CBT:1791.70
00024:CBT/CME DEC 2016 Rebate CBT:2575.54
00033:CBT/CME DEC 2016 Rebate CBT:3183.06
00071:CBT/CME DEC 2016 Rebate CBT:3701.60
00077:CBT/CME DEC 2016 Rebate CBT:1155.74
00099:CBT/CME DEC 2016 Rebate CBT:2406.90
00123:CBT/CME DEC 2016 Rebate CBT:1549.50
00201:CBT/CME DEC 2016 Rebate CBT:1740.60
00333:CBT/CME DEC 2016 Rebate CBT:2297.69
00375:CBT/CME DEC 2016 Rebate CBT:  80.36
00429:CBT/CME DEC 2016 Rebate CBT:3088.44
00451:CBT/CME DEC 2016 Rebate CBT: 150.90
00455:CBT/CME DEC 2016 Rebate CBT:3003.84
00525:CBT/CME DEC 2016 Rebate CBT:3222.04
00624:CBT/CME DEC 2016 Rebate CBT:5519.46
00708:CBT/CME DEC 2016 Rebate CBT:2213.46
00789:CBT/CME DEC 2016 Rebate CBT:2366.34
00877:CBT/CME DEC 2016 Rebate CBT:8292.10
00902:CBT/CME DEC 2016 Rebate CBT:1821.53
01900:CBT/CME DEC 2016 Rebate CBT: 249.58
01985:CBT/CME DEC 2016 Rebate CBT:-303.66
01986:CBT/CME DEC 2016 Rebate CBT:1002.40
05520:CBT/CME DEC 2016 Rebate CBT:1667.58
39009:CBT/CME DEC 2016 Rebate CBT:4363.68
88888:CBT/CME DEC 2016 Rebate CBT: 470.84
HERE

  date = Date.parse('20170110')
  currency = Currency.find_by_code('USD')

  #
  # create adjustment for credits
  #

  data.lines.each do |line|
    code, memo, amount = line.split(/:/)

    account = Account.find_by_code(code)

    Adjustment.transaction do
      begin
        journal_entry = JournalEntry.create! do |e|
          e.journal = Journal.find_by_code('SOLE')
          e.journal_entry_type = JournalEntryType.find_by_code('ADJ')
          e.account = account
          e.currency = currency
          e.posted_on = date
          e.as_of_on = date
          e.amount = amount
          e.memo = memo
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
