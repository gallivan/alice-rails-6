#
# This is used to setup EMM for the next year.
#

task "soy", [:base_posted_on, :this_posted_on, :next_posted_on] => :environment do |t, args|

  # base_posted_on - last business date of old year - get OTE for each currency
  # this_posted_on - first non-business date of new year - set OTE (or dummy one) as ledger balance for each currency
  # next_posted_on - first business date of new year - set adjustments to reverse OTE carried forward as ledger balance

  unless args[:base_posted_on] and args[:this_posted_on] and args[:next_posted_on]
    puts 'usage: soy[base_posted_on,this_posted_on,next_posted_on'
    puts 'usage: soy[YYYYMMDD,YYYYMMDD,YYYYMMDD]'
    puts 'usage: soy[20171229,20180101,20180103'
    exit
  end

  base_posted_on = Date.parse(args[:base_posted_on])
  this_posted_on = Date.parse(args[:this_posted_on])
  next_posted_on = Date.parse(args[:next_posted_on])

  puts "Running with the following parameters."
  puts
  puts "base_posted_on: #{base_posted_on}"
  puts "this_posted_on: #{this_posted_on}"
  puts "next_posted_on: #{next_posted_on}"
  puts
  puts "Waiting 60 seconds. Break to stop."
  sleep 60.seconds

  base_money_lines = MoneyLine.held.posted_on(base_posted_on)

  count = base_money_lines.count

  puts "Old money lines to process: #{count}"

  if count > 0
    puts "Continuing..."
  else
    puts "No money lines for #{base_posted_on}. Exiting."
    exit
  end

  sleep 5

  LedgerEntry.transaction do
    begin
      base_money_lines.each do |base_money_line|
        puts "Working MoneyLine: #{base_money_line.id}"
        account = base_money_line.account
        puts "Working Account: #{account.code}"
        puts "Working Currenty: #{base_money_line.currency.code}"
        puts "Working Segregation: #{base_money_line.segregation.code}"

        # use ledger balance of base_posted_on to create ledger balance for this_posted_on

        puts "Setup...."

        bml = base_money_line

        leg = account.ledger_entries.ledger.posted_on(bml.posted_on).for_currency(base_money_line.currency).for_segregation(base_money_line.segregation).order(:id).first
        ote = account.ledger_entries.ote.posted_on(leg.posted_on).for_currency(base_money_line.currency).for_segregation(base_money_line.segregation).order(:id).first

        #
        #  bring forward ote of base_posted_on as ledger balance this_posted_on
        #

        puts "Create LedgerEntry to bring forward OTE...."

        new_ledger_entry = leg.dup

        new_ledger_entry.id = nil
        new_ledger_entry.posted_on = this_posted_on
        new_ledger_entry.as_of_on = this_posted_on
        new_ledger_entry.amount = (ote.blank?) ? 0 : ote.amount
        new_ledger_entry.memo = 'EOY/SOY - OTE brought forward as Ledger Balance'
        new_ledger_entry.save!

        puts "New LedgerEntry: #{new_ledger_entry.id}."

        #
        # use ledger entry of this_posted_on to create journal entry and adjustment for next_posted_on
        #

        puts "Create Adjustment to reverse OTE LedgerEntry...."

        journal_entry = JournalEntry.create! do |e|
          e.journal = Journal.find_by_code('SOLE')
          e.journal_entry_type = JournalEntryType.find_by_code('ADJ')
          e.account = new_ledger_entry.account
          e.posted_on = next_posted_on
          e.as_of_on = next_posted_on
          e.amount = new_ledger_entry.amount * -1
          e.currency = new_ledger_entry.currency
          e.segregation = Segregation.find_by_code('SEGN')
          e.memo = 'Reverse OTE brought forward.'
        end

        puts "Create JournalEntry to reflect Adjustment...."

        puts "JNL #{journal_entry.account.code} #{journal_entry.posted_on} #{journal_entry.amount} #{journal_entry.currency.code}"

        adjustment = Adjustment.create! do |a|
          a.account = journal_entry.account
          a.adjustment_type = AdjustmentType.find_by_code('MSC')
          a.journal_entry = journal_entry
          a.posted_on = journal_entry.posted_on
          a.as_of_on = journal_entry.as_of_on
          a.amount = journal_entry.amount
          a.currency = journal_entry.currency
          a.segregation = journal_entry.segregation
          a.memo = journal_entry.memo
        end

        puts "ADJ #{adjustment.account.code} #{adjustment.posted_on} #{adjustment.amount} #{adjustment.currency.code}"

      end
    rescue Exception => e
      puts e.message
    end
  end
end