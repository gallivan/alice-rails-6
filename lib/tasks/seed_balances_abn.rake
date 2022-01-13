
task :seed_abn_baseline_balances, [:filename] => :environment do |t, args|
  unless args[:filename]
    puts "Usage: rake seed_abn_baseline_balances[filename]"
    exit
  end

  filename = args[:filename]

  puts "Baseline ledger balances"

  unless File.exist?(filename)
    puts "#{filename} does not exist. Exiting."
    exit
  end

  lines = File.readlines(filename)

  posted_on = Date.parse(lines[-1].split(',')[1])

  puts 'Get FX rates...'
  CurrencyMark.set_fx_rates(posted_on, 'Quandl')

  puts "Building HELD lines..."

  lines.each do |line|
    next unless line.match(/^M/)
    puts line

    ary = line.split(',')

    acc_code = ary[9]
    seg_code = ary[10]
    ccy_code = ary[11]
    amount = BigDecimal(ary[12], 8)

    acc_code = Builders::AccountBuilder.aacc_account_alias_mundger(acc_code)

    seg_code = seg_code.match(/(EU|SF|US|BP)/) ? 'SEG7' : 'SEGD'

    puts "#{acc_code} #{posted_on.strftime} #{ccy_code} #{seg_code} #{amount}"

    account = Account.find_by_code(acc_code)
    currency = Currency.find_by_code(ccy_code)
    segregation = Segregation.find_by_code(seg_code)

    entry = LedgerEntry.where(account_id: account.id, segregation_id: segregation.id, currency_id: currency.id).first

    entry.delete unless entry.blank?

    entry = LedgerEntry.create! do |e|
      e.ledger = Ledger.find_by_code('SOLE')
      e.account = account
      e.currency = currency
      e.segregation = segregation
      e.ledger_entry_type = LedgerEntryType.find_by_code('LEG')
      e.posted_on = posted_on
      e.as_of_on = posted_on
      e.amount = amount
      e.memo = 'rebuilt'
    end

    Builders::MoneyLineBuilder.build(entry)
  end

  puts 'done'

  # these will be built during eod for the date

  # puts 'Build BASE MoneyLines...'
  #
  # account_ids = MoneyLine.pluck(:account_id).sort.uniq
  #
  # account_ids.each do |id|
  #   account = Account.find(id)
  #   dates = account.money_lines.pluck(:posted_on).uniq.sort
  #   dates.each do |date|
  #     account.build_base_balances(date)
  #   end
  # end

  puts 'done'
end