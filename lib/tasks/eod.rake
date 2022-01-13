namespace :eod do

  # error on trap: log writing failed can't be called from trap context
  # fix for trap: https://github.com/mperham/sidekiq/blob/b6de0bae6b86d5abae25852141768d8ecc8ddedf/lib/sidekiq/cli.rb#L53

  trap('SIGINT') { Rails.logger.info "Caught SIGINT. Exiting."; exit }
  trap('SIGTERM') { Rails.logger.info "Caught SIGTERM. Exiting."; exit }

  # TRDCAPT_REGEX = /<TrdCaptRpt.+<\/TrdCaptRpt>/m
  # POSRPT_REGEX = /<PosRpt.+<\/PosRpt>/m
  #
  # FX_CODES = ["CHF", "DKK", "EUR", "GBP", "JPY", "NOK", "SEK", "USD"]
  #
  $sleep_time_long = 15.minutes
  $sleep_time_short = 5.minutes
  $sleep_very_short = 60.seconds

  gem 'rubyzip', require: 'zip'

  def pause(message)
    Rails.logger.info message
    print "Sleeping #{$sleep_very_short} seconds: #{message}"
    sleep $sleep_very_short
    puts "...continuing."
    Rails.logger.info "continuing"
  end

  def run(date)
    begin
      Rails.logger.info "eod:run begun at #{Time.now}"
      EodMailer.status('begun').deliver_now

      batch = Workers::EndOfDayBatch.new(date)

      batch.check_env
      batch.check_dirs
      batch.check_knobs
      batch.check_switches

      batch.clear_cache

      batch.update_house_group

      batch.check_picker_reports(date)
      batch.check_packer_reports(date)
      batch.check_booker_reports(date)

      batch.eod_cme(date)
      batch.eod_ghf(date) if RuntimeSwitch.is_on?(:load_ghf_activity)

      batch.block_on_bookings(date)
      batch.claim_name_reset

      if RuntimeSwitch.is_on?(:check_open_positions)
        batch.check_open_positions(date)
      else
        EodMailer.status('check_open_positions runtime switch is off').deliver_now
      end

      batch.check_claims
      batch.set_fx_rates(date)
      batch.get_claim_marks(date)
      batch.check_and_setup_chargeables(date)
      Claim.update_cme_contract_names
      batch.run_eod_for_accounts(date)
      batch.run_eod_reports(date)
      batch.calculate_margins(date)
      batch.send_large_trader_report_cme(date)
      batch.send_large_trader_report_cftc(date)

      EodMailer.status('ended').deliver_now

      Rails.logger.info "eod:run ended at #{Time.now}"
    rescue Exception => e
      Rails.logger.warn(e)
      EodMailer.status('abnormal exit').deliver_now
      exit 1
    end
    EodMailer.status('normal exit').deliver_now
    exit 0
  end

  task :run, [:date] => :environment do |t, args|
    date = nil
    begin
      Rails.logger.info "run task called with :date arg of #{args[:date]}"
      date = Date.parse(args[:date])
    rescue Exception => e
      puts "Invalid argument: #{e}"
      puts "Usage: rake eod:run['yyyymmdd']"
      puts "Usage: rake eod:run['yyyy-mm-dd']"
      Rails.logger.warn "eod:run call failed. Exiting."
    end
    begin
      pause("About to call method 'run' for date #{date}")
      run(date)
    rescue Exception => e
      Rails.logger.warn "eod:run failed with #{e}. Exiting."
      exit 0
    end
  end

  task :run_reverse, [:date] => :environment do |t, args|
    begin
      date = Date.parse(args[:date])
    rescue Exception => e
      puts "Invalid argument: #{e}"
      puts "Usage: rake eod:run_reverse['yyyy-mm-dd']"
      exit 0
    end

    Rails.logger.info Time.now

    batch = Workers::EndOfDayBatch.new(date)
    batch.run_eod_reverse_for_accounts(date)

    Rails.logger.info Time.now
  end

  task :set_holiday_marks, [:venue_code, :posted_on] => :environment do |t, args|
    if args[:venue_code].blank? or args[:posted_on].blank?
      puts "Usage: rake eod:set_holiday_marks[<venue_code>,<posted_on>]"
      puts "Usage: rake eod:set_holiday_marks[CBT,2016-08-09]"
      puts "posted_on is the holiday date."
      exit 0
    end

    begin
      dat = Date.parse(args[:posted_on])
    rescue Exception => e
      puts "Invalid date: #{args[:posted_on]}"
      exit
    end

    str = "#{args[:venue_code]}:%"

    claims = Claim.where('code like ?', str).order(:code)

    claims.each do |claim|
      next unless claim.claim_type.code == 'FUT'
      if claim.claim_marks.blank?
        puts "Skipping with #{claim.code}...no marks to promote"
      else
        print "Working with #{claim.code}..."
        #
        # todo fix this awful hack
        #
        if claim.expires_on < dat
          puts "Expired."
        else
          last_mark = claim.claim_marks.order(:id).last
          print "ClaimMark of #{last_mark.mark} for #{last_mark.claim.code} as of #{dat}..."
          if last_mark.posted_on == dat
            puts "Exists"
          else
            ClaimMark.create! do |m|
              m.system_id = last_mark.system_id
              m.claim_id = last_mark.claim_id
              m.posted_on = dat
              m.mark = last_mark.mark
              m.approved = true
            end
            puts "Posted."
          end
        end
      end
    end
  end

  task :eod_loop_over_dates, [:fm_date, :to_date] => :environment do |t, args|
    if args[:fm_date] and args[:to_date]
      fm_date = Date.parse(args[:fm_date])
      to_date = Date.parse(args[:to_date])
      eod_loop_over_dates(fm_date, to_date)
    else
      puts "Usage: rake eod:eod_loop_over_dates[yyyy-mm-dd,yyyy-mm-dd]"
      puts "Usage: rake eod:eod_loop_over_dates[2017-01-01,2017-01-31]"
      exit 1
    end
  end

  task :sync_dumps, [:src, :dst] => :environment do |t, args|
    if Rails.env.production?
      msg = "begun at #{Time.now}: #{t}"
      EodMailer.status(msg).deliver_now
      Rails.logger.info msg

      src = args[:src].blank? ? '/home/alice/dumps' : args[:src]
      dst = args[:dst].blank? ? 'alice@emm3.jackijack.com:~/' : args[:dst]
      sync_files(src, dst)

      msg = "ended at #{Time.now}: #{t}"
      EodMailer.status(msg).deliver_now
      Rails.logger.info msg
    else
      msg = "not production so no-op at #{Time.now}: #{t}"
      EodMailer.status(msg).deliver_now
      Rails.logger.info msg
    end
  end

  task :sync_var, [:src, :dst] => :environment do |t, args|
    if Rails.env.production?
      msg = "begun at #{Time.now}: #{t}"
      EodMailer.status(msg).deliver_now
      Rails.logger.info msg

      src = args[:src].blank? ? '/home/alice/var' : args[:src]
      dst = args[:dst].blank? ? 'alice@emm3.jackijack.com:~/' : args[:dst]
      sync_files(src, dst)

      msg = "ended at #{Time.now}: #{t}"
      EodMailer.status(msg).deliver_now
      Rails.logger.info msg
    else
      msg = "not production so no-op at #{Time.now}: #{t}"
      EodMailer.status(msg).deliver_now
      Rails.logger.info msg
    end
  end

  def eod_loop_over_dates(fm_date, to_date)
    Rails.logger.info "Fm Date #{fm_date}"
    Rails.logger.info "To Date #{to_date}"
    dates = fm_date..to_date
    dates.each do |date|
      next if date.saturday? or date.sunday?
      puts "Running EOD for #{date}"
      run(date)
    end
  end

  def sync_files(src, dst)
    #opts = '--rsh ssh --recursive --perms --owner --times --group --times --verbose --rsh=ssh --links'
    opts = '--rsh ssh --delete --recursive --perms --owner --times --group --times --verbose --rsh=ssh --links'
    system "rsync #{opts} #{src} #{dst}"
  end

end