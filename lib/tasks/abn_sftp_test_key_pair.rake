task :abn_sftp_test_key_pair, [:date] => :environment do  |t, args|
  puts "begun #{t.name}"
  if args[:date].blank?
    puts "Usage: rake #{t.name}[YYYY-MM-DD]"
    exit
  end
  date = Date.parse(args[:date])
  date_str = date.strftime('%Y%m%d')
  filename = "Intraday6_MICS_#{date_str}.csv"
  picker = Workers::PickerOfItdAbn.new
  picker.setup_file(filename)
  puts "ended #{t.name}"
end