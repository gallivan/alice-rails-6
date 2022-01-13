task :abn_sftp_test => :environment do
  date_str = Date.today.strftime('%Y%m%d')

  filename = "INTRADAY_#{date_str}.CSV"

  picker = Workers::PickerOfItdAbn.new
  picker.setup_file(filename)

end