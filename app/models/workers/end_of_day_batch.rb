module Workers
  class EndOfDayBatch
    # TRDCAPT_REGEX = /<TrdCaptRpt.+<\/TrdCaptRpt>/m
    # POSRPT_REGEX = /<PosRpt.+<\/PosRpt>/m

    FX_CODES = ["CHF", "DKK", "EUR", "GBP", "JPY", "NOK", "SEK", "USD"]

    $sleep_time_long = 15.minutes
    $sleep_time_short = 5.minutes
    $sleep_very_short = 60.seconds

    def initialize(date)
      @date = date
    end

    def clear_cache
      EodMailer.status('Clearing cache').deliver_now
      Rails.cache.clear
    end

    def update_house_group
      EodMailer.status('begun filling HOUSE group').deliver_now
      # every account should be a HOUSE member for EMM
      group_account = Account.find_by_code('HOUSE')
      Account.where("code != 'HOUSE'").update_all(group_id: group_account.id)
      EodMailer.status('ended filling HOUSE group').deliver_now
    end

    def check_env
      Rails.logger.info "Calling #{self.class}##{__method__}"
      missing = []
      seeking = %W( LRG_DIR TXT_DIR PDF_DIR DNL_DIR )
      seeking.each { |key| missing << key unless ENV[key] }
      raise "env_check fail: #{missing}" unless missing.empty?
    end

    def check_dirs
      Rails.logger.info "Calling #{self.class}##{__method__}"
      missing = []
      seeking = %W(LRG_DIR TXT_DIR PDF_DIR DNL_DIR)
      seeking.each do |key|
        missing << key unless File.exists?(ENV[key])
        if key.match(/DNL_DIR/)
          %W(cme abn spn).each { |x| missing << "#{ENV[key]}/#{x}" unless File.exists?("#{ENV[key]}/#{x}") }
        end
      end
      raise "check_dirs fail: #{missing}" unless missing.empty?
    end

    def check_switches
      Rails.logger.info "Calling #{self.class}##{__method__}"
      unless RuntimeSwitch.all_found?
        msg = "RuntimeSwitch has missing elements."
        EodMailer.alert(msg).deliver_now
        Rails.logger.warn msg
        raise "Missing switches"
      end
    end

    def check_knobs
      Rails.logger.info "Calling #{self.class}##{__method__}"
      unless RuntimeKnob.all_found?
        msg = "RuntimeKnob has missing elements."
        EodMailer.alert(msg).deliver_now
        Rails.logger.warn msg
        raise "Missing knobs"
      end
    end

    def check_picker_reports(date)
      Rails.logger.info "Checking PickerReport count..."
      count = PickerReport.fail.where(posted_on: date).count
      if count > 0
        Rails.logger.info "Fail."
        Rails.logger.info "PickerReport count is #{count}. Exiting."
        exit 1
      else
        Rails.logger.info "Okay."
      end
    end

    def check_packer_reports(date)
      Rails.logger.info "Checking PackerReport count..."
      count = PackerReport.fail.where(posted_on: date).count
      if count > 0
        Rails.logger.info "Fail."
        Rails.logger.info "PackerReport count is #{count}. Exiting."
        exit 1
      else
        Rails.logger.info "Okay."
      end
    end

    def check_booker_reports(date)
      Rails.logger.info "Checking BookerReport count..."
      count = BookerReport.fail.where(posted_on: date).count
      if count > 0
        Rails.logger.info "Fail."
        Rails.logger.info "BookerReport count is #{count}. Exiting."
        exit 1
      else
        Rails.logger.info "Okay."
      end
    end

    def block_on_bookings(date)
      # Because other process
      # are handling the post
      # and book of activity.
      while true
        Rails.logger.info '-' * 30
        picker_count_cme = PickerReport.where(posted_on: date).eod_cme.count
        booker_count_cme = BookerReport.where(posted_on: date).eod_cme.count

        picker_count_ghf = PickerReport.where(posted_on: date).eod_ghf.count
        booker_count_ghf = BookerReport.where(posted_on: date).eod_ghf.count

        Rails.logger.info "EOD picker/booker counts EOD_CME: #{picker_count_cme}/#{booker_count_cme}"
        Rails.logger.info "EOD picker/booker counts EOD_GHF #{picker_count_ghf}/#{booker_count_ghf}"

        break if picker_count_cme == booker_count_cme and picker_count_ghf == booker_count_ghf

        Rails.logger.info "EOD sleeping until #{$sleep_time_short.from_now}."
        sleep $sleep_time_short
      end
    end

    def claim_name_reset
      ClaimSet.all.each do |claim_set|
        claim_set.claims.each do |claim|
          next unless claim.claimable.is_a? Future
          #
          # todo not happy with this as the location
          # but i don't want to much about with the
          # expires_on the Future associated right now.
          #
          if claim.claim_set.code == 'CME:SR1'
            date = claim.claimable.expires_on - 1.months
            name = "#{claim.claim_set.name} #{date.strftime('%b %Y')}"
          elsif claim.claim_set.code == 'CME:SR3'
            date = claim.claimable.expires_on - 3.months
            name = "#{claim.claim_set.name} #{date.strftime('%b %Y')}"
          else
            name = "#{claim.claim_set.name} #{claim.claimable.expires_on.strftime('%b %Y')}"
          end
          Rails.logger.info '.' * 20
          Rails.logger.info "Old: #{claim.name}"
          Rails.logger.info "New: #{name}"
          claim.update_attribute(:name, name)
        end
      end
    end

    def check_open_positions(date)
      Rails.logger.info "Checking open positions..."
      # futures = Future.expired_or_expiring(Date.parse('2016-04-01'))
      futures = Future.expired(date)
      positions = []
      futures.each do |future|
        positions << future.claim.positions.open
      end
      positions.flatten!
      unless positions.blank?
        lines = []
        positions.each do |position|
          lines << "Account #{position.account.code} has an open position in #{position.claim.code} expired after #{date}.\n"
        end
        Rails.logger.fatal lines
        EodMailer.open_positions_alert(lines).deliver_now
        EodMailer.alert('OPEN POSITIONS IN EXPIRED CLAIMS. EXITING EOD.').deliver_now
        exit 1 # because this should not happen
      else
        Rails.logger.info "Okay."
      end
    end

    def find_claims_with_ukn_ccy
      ids = Claim.joins(:point_currency).where("currencies.code = 'UKN'").pluck("claims.id")
      Claim.find(ids)
    end

    def fix_claims_with_ukn_ccy(claims)
      Rails.logger.info "Fixing known claim UKN currency problems."
      Rails.logger.info "ICE contracts can be found at: https://www.theice.com/products"
      claims.each do |claim|
        if claim.code.match(/^IFEU:G[FGHJKMNQUVXZ][0-9]{2}/)
          currency = Currency.usd
          Rails.logger.info "Setting currency to #{currency.code} for claim #{claim.code}."
          claim.update_attribute(:point_currency_id, currency.id)
        else
          Rails.logger.info "Could not fix #{claim.code}."
        end
      end
    end

    def fix_positions_with_ukn_ccy(claims)
      Rails.logger.info "Fixing known position UKN currency problems."
      claims.each do |claim|
        if claim.code.match(/^IFEU:G[FGHJKMNQUVXZ][0-9]{2}/)
          currency = Currency.usd
          claim.positions.each do |position|
            Rails.logger.info "Setting currency to #{currency.code} for position #{position.id} with claim #{claim.code}."
            position.update_attribute(:currency_id, currency.id)
          end
        else
          Rails.logger.info "Could not fix positions with #{claim.code}."
        end
      end
    end

    def check_claims
      claims = find_claims_with_ukn_ccy
      until claims.blank?
        Rails.logger.info "EOD should not run when claims have UKN currency."
        fix_claims_with_ukn_ccy(claims)
        fix_positions_with_ukn_ccy(claims)
        claims = find_claims_with_ukn_ccy
        claims.each do |claim|
          Rails.logger.info "Claim id #{claim.id} with code #{claim.code} and an UKN currency."
        end
        Rails.logger.info "EOD sleeping until #{$sleep_time_long.from_now}."
        sleep $sleep_time_long
      end
    end

    def check_fx_rates(date)
      missing = FX_CODES.dup
      until missing.empty? do
        FX_CODES.each do |code|
          currency = Currency.find_by_code(code)
          missing.delete(code) if currency.currency_marks.posted_on(date)
        end
        unless missing.empty?
          msg = "Missing CurrencyMarks for #{missing}. Checking again at #{15.minutes.from_now}."
          Rails.logger.warn(msg)
          sleep 15.minutes
        end
      end
    end

    def load_settlements_from_cme(claims, date)
      worker = Workers::CmeDAO.new
      while true do
        worker.set_marks(claims, date)
        if ClaimMark.missing_marks_for_date?(date, claims)
          sleep_time = RuntimeKnob.code_for_name('quandl_sleep_time').to_i || 5
          Rails.logger.warn "EOD Missing CME ClaimMark settlements"
          msg = "EOD sleeping until #{sleep_time.minutes.from_now}."
          Rails.logger.warn msg
          sleep sleep_time.minutes
        else
          break
        end
      end
    end

    def load_settlements_from_cbt(claims, date)
      worker = Workers::CmeDAO.new
      while true do
        worker.set_marks(claims, date)
        if ClaimMark.missing_marks_for_date?(date, claims)
          sleep_time = RuntimeKnob.code_for_name('quandl_sleep_time').to_i || 5
          Rails.logger.warn "EOD Missing CBT ClaimMark settlements"
          msg = "EOD sleeping until #{sleep_time.minutes.from_now}."
          Rails.logger.warn msg
          sleep sleep_time.minutes
        else
          break
        end
      end
    end

    def load_settlements_from_quandl(claims, date)
      while true do
        Workers::QuandlDAO.get_quandl_marks(date, claims)
        if ClaimMark.missing_marks_for_date?(date, claims)
          sleep_time = RuntimeKnob.code_for_name('quandl_sleep_time').to_i || 5
          Rails.logger.warn "EOD Missing ClaimMark settlements"
          msg = "EOD sleeping until #{sleep_time.minutes.from_now}."
          Rails.logger.warn msg
          sleep sleep_time.minutes
        else
          break
        end
      end
    end

    def get_claim_marks(date)
      EodMailer.status('begun getting marks').deliver_now
      claims = (ClaimMark.claims_to_mark_for_date(date)).to_set.delete(nil)
      cme_claims = (claims.each.map { |claim| claim if claim.entity.code =~ /CME/ }).to_set.delete(nil)
      cbt_claims = (claims.each.map { |claim| claim if claim.entity.code =~ /CBT/ }).to_set.delete(nil)
      claims = claims - cme_claims
      claims = claims - cbt_claims
      load_settlements_from_cme(cme_claims, date) unless cme_claims.blank?
      load_settlements_from_cbt(cbt_claims, date) unless cbt_claims.blank?
      load_settlements_from_quandl(claims, date) unless claims.blank?
      check_claim_marks_sanity(date)
      EodMailer.status('ended getting marks').deliver_now
    end

    def claim_sets_missing_chargeables(date)
      missing = []
      claim_ids = DealLegFill.posted_on(date).pluck(:claim_id).uniq.sort
      claim_set_ids = Claim.where("id in (?)", claim_ids).pluck(:claim_set_id).uniq.sort
      claim_sets = ClaimSet.find(claim_set_ids)
      claim_sets.each do |claim_set|
        claim_set.reload
        missing << claim_set if claim_set.chargeables.empty?
      end
      missing
    end

    def check_and_setup_chargeables(date)
      claim_sets = claim_sets_missing_chargeables(date)

      claim_sets.each do |claim_set|
        msg = "Missing Chargeable for ClaimSet #{claim_set.name} [#{claim_set.code}]. Creating default of 0.00 USD."
        Rails.logger.warn(msg)
        EodMailer.alert(msg).deliver_now

        Chargeable.create! do |c|
          c.claim_set = claim_set
          c.chargeable_type = ChargeableType.find_by_code('EXG')
          c.currency = Currency.usd
          c.amount = 0.0
          c.begun_on = date
          c.ended_on = 5.years.from_now
        end

        Chargeable.create! do |c|
          c.claim_set = claim_set
          c.chargeable_type = ChargeableType.find_by_code('SRV')
          c.currency = Currency.usd
          c.amount = 0.035
          c.begun_on = date
          c.ended_on = 5.years.from_now
        end

      end
    end

    def run_eod_for_account(account, date)
      msg = "Running EOD account #{account.code} for #{date}"
      Rails.logger.info msg
      (account.reg? or account.enm?) ? account.eod_for(date) : account.eod_for_group(date)
    end

    def run_eod_for_accounts(date)
      EodMailer.status('begun run_eod_for_accounts').deliver_now

      # regular accounts
      accounts = Account.reg.active.order(:code)
      accounts.each { |account| run_eod_for_account(account, date) }

      # exchange non-member accounts
      accounts = Account.enm.active.order(:code)
      accounts.each { |account| run_eod_for_account(account, date) }

      # group accounts
      accounts = Account.grp.active.order(:code)
      accounts.each { |account| run_eod_for_account(account, date) }

      EodMailer.status('ended run_eod_for_accounts').deliver_now
    end

    def run_eod_reverse_for_accounts(date)
      accounts = Account.active.order(:code)
      accounts.each do |account|
        msg = "Running EOD REVERSE account #{account.code} for #{date}"
        puts msg
        Rails.logger.info msg
        account.reverse_eod_for(date)
      end
    end

    def run_eod_reports(date)
      EodMailer.status('begun generating reports').deliver_now
      report_names = []

      report_names << 'daily_charges_by_account'
      report_names << 'daily_charges_by_exchange'
      report_names << 'monthly_charges_by_account'
      report_names << 'monthly_charges_by_exchange'
      report_names << 'firm_open_positions'
      report_names << 'account_money_lines'
      report_names << 'firm_money_lines'
      report_names << 'realized_pnl_and_ote_day_mtd_ytd'

      report_names.each do |name|
        EodMailer.status("begun generating report #{name}").deliver_now
        Builders::ReportBuilder.for(name, date)
        EodMailer.status("ended generating report #{name}").deliver_now
      end

      EodMailer.status('ended generating reports').deliver_now
    end

    def send_regulatory_reports(date)
      if Rails.env.production?
        cme = Workers::LargeTraderReportCme.new
        cme.report(date)
        cftc = Workers::LargeTraderReportCftc.new
        cftc.report(date)
      end
    end

    def check_claim_marks_sanity(date)
      failed = []
      tolerance = 0.1

      ids = ClaimMark.posted_on(date).order(:id).pluck(:id)

      ids.each do |id|
        claim_mark = ClaimMark.find(id)
        claim = claim_mark.claim
        Rails.logger.info "Checking #{claim.code} #{claim_mark.mark}"
        marks = claim.claim_marks.order(:id).limit(5).pluck(:mark)
        mark_avg = BigDecimal(marks.inject { |sum, el| sum + el }.to_f / marks.size, 8)
        lower = mark_avg * (1 - tolerance)
        upper = mark_avg * (1 + tolerance)
        mark_dif = (100 * (claim_mark.mark - mark_avg) / mark_avg).to_i.abs
        if mark_avg.between?(lower, upper)
          Rails.logger.info "...within tolerance"
        else
          if mark.approved?
            print "...outside tolerance but approved: "
          else
            print "...outside tollerance"
            failed << claim
          end
          print (mark_dif > mark) ? "high" : "low"
          Rails.logger.info " by #{mark_dif}%"
        end
        unless failed.empty?
          failed.each do |claim|
            Rails.logger.info "ClaimMark #{claim.code} outside tolerance and not approved."
          end
          Rails.logger.info "Exiting"
          exit 1
        end
      end
    end

    def set_fx_rates(date)
      EodMailer.status('begun getting FX marks').deliver_now
      CurrencyMark.set_fx_rates(date, 'Quandl')
      check_fx_rates(date)
      EodMailer.status('ended getting FX marks').deliver_now
    end

    def eod_cme(date)
      picker = Workers::PickerOfEodCme.new
      packer = Workers::PackerOfEodCme.new
      booker = Workers::BookerOfEodCme.new

      picker_reports = picker.pick(date)

      picker_reports.each do |picker_report|
        Rails.logger.info "eod:handling picker_report"
        packed = packer.pack(picker_report)
        booked = booker.book(packed)
      end
    end

    def eod_ghf(date)
      picker = Workers::PickerOfEodGhf.new
      packer = Workers::PackerOfEodGhf.new
      booker = Workers::BookerOfEodGhf.new

      picker_reports = picker.pick(date)

      picker_reports.each do |picker_report|
        Rails.logger.info "eod:handling picker_report"
        packed = packer.pack(picker_report)
        booked = booker.book(packed)
      end
    end

    def calculate_margins(date)
      margin_calculator = MarginCalculator.first
      margin_calculator.calculate_margins_for_date(date)
    end

    def send_large_trader_report_cme(date)
      worker = Workers::LargeTraderReportCme.new
      worker.report(date)
    end

    def send_large_trader_report_cftc(date)
      worker = Workers::LargeTraderReportCftc.new
      worker.report(date)
    end

    def get_span_file(src_filename, dst_filename)
      Rails.logger.info "SRC: #{src_filename}"
      Rails.logger.info "DST: #{dst_filename}"
      File.unlink(dst_filename) if File.exist? dst_filename
      Net::FTP.open('ftp.cmegroup.com') do |ftp|
        ftp.login
        ftp.getbinaryfile(src_filename, dst_filename, 1024)
      end
    end

  end
end
