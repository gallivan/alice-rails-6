task :a => :environment do
  dates = find_dates
  eod_reverse_for(dates)
  eod_for(dates)
end

def find_dates
  sql = "
      select distinct posted_on
      from deal_leg_fills
      where posted_on >= '2016-06-01'
      order by posted_on
    "
  ActiveRecord::Base.connection.select_values(sql)
end

def eod_reverse_for(dates)
  dates.reverse.each do |date|
    posted_on = Date.parse(date)
    Account.all.each do |account|
      base = Account::BASE_FILE_NAMES.first
      filename = account.build_filename(base, posted_on, 'txt')
      status = "Account #{account.code} EOD reverse for #{posted_on}: "
      if File.file?(filename)
        puts status + 'work'
        account.reverse_eod_for(posted_on)
      else
        puts status + 'skip'
      end
    end
  end
end

def eod_for(dates)
  dates.each do |date|
    puts date
    system "rake eod:mark[#{date}]" # cannot repeatedly invoke the task
    posted_on = Date.parse(date)
    Account.all.each do |account|
      puts "Account #{account.code} EOD for #{posted_on}: work"
      account.eod_for(posted_on)
    end
  end
end