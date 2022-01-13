task :create_margin_for_account, [:code, :date] => :environment do |t, args|
  puts "begun #{t.name}"

  if args[:code].blank? or args[:date].blank?
    puts "Usage: rake t.name[<code>,<date>]"
    puts "Usage: rake t.name['00123','2018-03-13']"
    exit
  end

  begin
    code = args[:code]
    date = Date.parse(args[:date])
    account = Account.find_by_code(code)
    margin_calculator = MarginCalculator.first
    margin_calculator.calculate_margin_for_account(account, date)
  rescue Exception => e
    puts "Failed: #{e}"
  end

  puts "ended #{t.name}"
end
