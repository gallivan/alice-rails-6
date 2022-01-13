def build_enteries(line, index, code, posted_on, account, ccy)
  ary = line.split(/\s+/)
  val = ary[index].gsub(',', '')
  bal = BigDecimal(val, 8)

  seg = Segregation.find_by_code('SEGN')
  typ = LedgerEntryType.find_by_code(code)

  ledger_entry = LedgerEntry.where(account_id: account.id, currency_id: ccy.id, segregation_id: seg.id, ledger_entry_type_id: typ.id, posted_on: posted_on).first
  ledger_entry.delete unless ledger_entry.blank?

  entry = LedgerEntry.create! do |e|
    e.ledger = Ledger.find_by_code('SOLE')
    e.ledger_entry_type = typ
    e.account = account
    e.currency = ccy
    e.segregation = seg
    e.amount = bal
    e.posted_on = posted_on
    e.as_of_on = posted_on
    e.memo = 'baseline build'
  end

  puts "#{code} #{entry.posted_on} #{entry.account.code} #{entry.currency.code} #{entry.segregation.code} #{entry.amount} "

  money_line = Builders::MoneyLineBuilder.build(entry)

  puts "#{code} #{money_line.posted_on} #{money_line.account.code} #{money_line.currency.code} #{money_line.segregation.code} #{money_line.kind} #{money_line.ledger_balance}"

  entry
end

def set_posted_on(line)
  Date.parse(line.split(/:/)[1].strip)
end

def set_account(line)
  ary = line.split(/:/)
  code = ary[4].split(/-/)[0].strip
  Account.find_by_code(code)
end

def set_currency(line)
  ary = line.split(/\s+/)
  Currency.find_by_code(ary.first)
end

def set_currency_mark(line, ccy, posted_on)
  ary = line.split(/\s+/)
  mrk = BigDecimal(ary[1].to_f.round(6), 8)
  ccy_mrk = CurrencyMark.where(currency_id: ccy.id, posted_on: posted_on).first
  mrk = (1/mrk).round(6) if ccy.code.match(/(EUR|GBP|AUD|NZD)/)
  if ccy_mrk.blank?
    params = {
        currency_id: ccy.id,
        posted_on: posted_on,
        mark: mrk
    }
    CurrencyMark.create!(params)
  else
    ccy_mrk.update_attribute(:mark, mrk)
  end
  ccy_mrk
end

task :seed_balances_eoy, [:filename] => :environment do |t, args|

  unless args[:filename]
    puts "Money filename missing?"
    puts "Usage: rake seed_balances[filename]"
    exit
  end

  filename = args[:filename]

  unless File.exists?(filename)
    puts "#{filename} does not exist. Exiting."
    exit
  end

  puts "Building baseline ledger balances"

  puts "Building HELD lines..."

  ccy = nil
  leg = nil
  ote = nil
  account = nil
  posted_on = nil
  balance_line_one_is_next = false
  balance_line_two_is_next = false
  base_balance_is_next = false

  File.open(filename).readlines.each do |line|
    # puts '.++.' * 30
    # puts line

    next if line.match(/CONVERSION RATE/)

    if base_balance_is_next
      base_balance_is_next = false
      next
    end

    if line.match(/USD BASE CONVERSION/)
      base_balance_is_next = true
      next
    end

    posted_on = set_posted_on(line) if line.match(/CREATED FOR/)

    if line.match(/ORIGIN.*ACCOUNT/)
      account = set_account(line)
      ccy = nil
      leg = nil
      ote = nil
    end

    if line.match(/^(USD|EUR|GBP|CHF|JPY|AUD|NZD)/)
      ccy = set_currency(line)
      mrk = set_currency_mark(line, ccy, posted_on)
      leg = build_enteries(line, 8, 'LEG', posted_on, account, ccy)
    end

    if line.match(/^\s{27}[\*]{20}/)
      ote = build_enteries(line, 3, 'OTE', posted_on, account, ccy)
    end

    # puts "Posted: #{posted_on}" if posted_on
    # puts "Account: #{account.code}" if account
    # puts "CCY: #{ccy.code}" if ccy
    # puts "LEG: #{leg.amount}" if leg
    # puts "OTE: #{ote.amount}" if ote

  end

  puts 'done'

  puts 'Build BASE MoneyLines...'

  account_ids = MoneyLine.pluck(:account_id).sort.uniq

  account_ids.each do |id|
    account = Account.find(id)
    dates = account.money_lines.pluck(:posted_on).uniq.sort
    dates.each do |date|
      base = account.build_base_balances(date)
      # 2016-10-20 88888 EUR SEG7 1889586.57
      puts "#{base.posted_on} #{base.account.code} #{base.currency.code} #{base.segregation.code} #{base.kind} #{base.ledger_balance}"
    end
  end

  puts 'done'
end