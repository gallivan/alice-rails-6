task :ghf_sftp_test => :environment do
  begin
    puts "begun"
    date = Date.parse('2021-09-03')
    puts "Date set to #{date}"
    date_str = date.strftime('%d%m%Y')
    puts "Date rep set to #{date_str}"
    filename = "MIR13_LON_EMMGRP_#{date_str}.csv"
    puts "Filename set to #{filename}"
    picker = Workers::PickerOfEodGhf.new
    puts "Trying sftp..."
    picker.setup_file(filename)
    puts "ended"
  rescue Exception => e
    puts "Exception: #{e}"
    Rails.logger.warn "Exception: #{e}."
  end
end