module Builders
  class ReportBuilder

    LINES_PER_PAGE = 50

    def self.build(params)
      #
      # todo perhaps i should not define these types ... since is a kind of seeding
      #
      report_type = ReportType.where(code: params[:report_type_code]).first_or_create(code: params[:report_type_code], name: params[:report_type_code])
      format_type = FormatType.where(code: params[:format_type_code]).first_or_create(code: params[:format_type_code], name: params[:format_type_code])

      # Report.where(posted_on: params[:posted_on], report_type: report_type, format_type: format_type).delete_all
      Report.where(location: params[:location]).delete_all

      Report.create! do |r|
        r.report_type = report_type
        r.format_type = format_type
        r.posted_on = params[:posted_on]
        r.memo = params[:memo]
        r.location = params[:location]
      end
    end

    def self.for(name, date)
      method_name = "query_#{name}"

      if self.methods.include? method_name.to_sym
        results = self.send(method_name, date)

        lines = format_results(name, results)
        lines = insert_report_header(name, lines)
        lines = insert_report_footer(name, lines)
        lines = paginate_report(name, lines)
      else
        # todo raise exception?
        lines = ["Method query_#{name} not found. Could not run report."]
      end

      txt_filename = write_txt(name, date, lines)

      params = {
        posted_on: date,
        format_type_code: 'TXT',
        report_type_code: name,
        memo: "#{name} #{date}",
        location: txt_filename
      }
      self.build(params)

      pdf_filename = write_pdf(name, date, txt_filename)

      params = {
        posted_on: date,
        format_type_code: 'PDF',
        report_type_code: name,
        memo: "#{name} #{date}",
        location: pdf_filename
      }
      self.build(params)

      puts lines.count
    end

    private

    def self.format_results(name, results)
      lines = []
      results.each { |result| lines << format_result(name, result) }
      lines
    end

    def self.insert_report_header(name, lines)
      lines
    end

    def self.insert_report_footer(name, lines)
      method_name = "report_footer_#{name}"
      (self.methods.include? method_name.to_sym) ? self.send(method_name, lines) : lines
    end

    def self.report_footer_daily_charges_by_account(lines)
      self.send('report_footer_daily_charges_by_exchange', lines)
    end

    def self.report_footer_daily_charges_by_exchange(lines)
      charges = {}
      lines.each do |line|
        next if line.split.count != 5
        line.chomp!
        _, _, _, ccy, chg = line.split
        charges[ccy].nil? ? charges[ccy] = BigDecimal(chg) : charges[ccy] += BigDecimal(chg)
      end
      lines << "\n"
      charges.keys.sort.each do |key|
        line = "#{key} #{sprintf("%16.2f", charges[key])}\n"
        lines << line
      end
      lines
    end

    def self.report_footer_monthly_charges_by_account(lines)
      self.send('report_footer_monthly_charges_by_exchange', lines)
    end

    def self.report_footer_monthly_charges_by_exchange(lines)
      charges = {}
      lines.each do |line|
        next if line.split.count != 6
        line.chomp!
        _, _, _, ccy, chg, _ = line.split
        charges[ccy].nil? ? charges[ccy] = BigDecimal(chg) : charges[ccy] += BigDecimal(chg)
      end
      lines << "\n"
      charges.keys.sort.each do |key|
        line = "#{key} #{sprintf("%16.2f", charges[key])}\n"
        lines << line
      end
      lines
    end

    def self.paginate_report(name, lines)
      page_line = 1
      page_number = 1
      out = [insert_page_header(name)]
      lines.each do |line|
        page_line += line.count("\n")
        # puts "#{lines.count} #{page_line} #{page_number} #{line}"
        out << line
        if page_line >= LINES_PER_PAGE
          page_line = 1
          page_number += 1
          out << insert_page_footer(name)
          out << ("\f")
          out << insert_page_header(name)
        end
      end
      out
    end

    def self.write_txt(name, date, lines)
      txt_filename = build_filename(name, date, 'txt')
      txt_file = File.new(txt_filename, 'w')
      lines.each { |line| txt_file.write(line) }
      txt_file.close
      txt_filename
    end

    def self.write_pdf(name, date, txt_filename)
      pdf_filename = build_filename(name, date, 'pdf')
      header = "EMM #{name} #{date} " + '|%D %C|Page $% of $='
      begin
        system "enscript #{txt_filename} --font=Courier8 --header=\'#{header}\' --landscape -o - | ps2pdf - #{pdf_filename}"
      rescue Exception => e
        msg = "PDF generation exception: #{e.message}"
        Rails.logger.warn(msg)
        EodMailer.status(msg).deliver_now
      end
      pdf_filename
    end

    # TODO next method dupe ofcode from account.rb

    def self.build_filename(name, date, format)
      root = ENV['TXT_DIR'] if format == 'txt'
      root = ENV['PDF_DIR'] if format == 'pdf'
      path = "#{root}/#{date.strftime('%Y%m%d')}"
      FileUtils.mkdir_p path unless Dir.exist? path
      filename = "#{name}_#{date.strftime('%Y%m%d')}"
      "#{path}/#{filename}.#{format}"
    end

    def self.insert_page_header(name)
      method_name = "format_#{name}_page_header".to_sym
      (self.methods.include? method_name) ? self.send(method_name) : "\n"
    end

    def self.insert_page_footer(name)
      method_name = "format_#{name}_page_footer".to_sym
      (self.methods.include? method_name) ? self.send(method_name) : "\n"
    end

    def self.format_result(name, result)
      method_name = "format_#{name}".to_sym
      (self.methods.include? method_name) ? self.send(method_name, result) : "#{self.name} #{method_name} not found.\n"
    end

    def self.format_firm_money_lines_page_header
      heads = %W(Posted CCY Seg Kind Begin Charges Adj PnL Ledger OTE Cash Net Mark)
      "%10s %3s %4s %4s %10s %10s %10s %10s %10s %10s %10s %10s %11s\n" % heads
    end

    def self.format_firm_money_lines(result)
      keys = ['posted_on', 'currency_code', 'segregation_code', 'kind', 'beginning_balance', 'charges']
      keys << ['adjustments', 'pnl_futures', 'ledger_balance', 'open_trade_equity', 'cash_account_balance']
      keys << ['net_liquidating_balance', 'currency_mark']
      keys = keys.flatten

      vals = []
      keys.each { |key| vals << result[key] }

      if result['currency_mark'].blank?
        "%10s %3s %4s %4s %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f\n" % vals
      else
        "%10s %3s %4s %4s %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f %11.6f\n" % vals
      end
    end

    def self.format_account_money_lines_page_header
      heads = %W(Posted Account CCY Seg Kind Begin Charges Adj PnL Ledger OTE Cash Net Mark)
      "%10s %10s %3s %4s %4s %10s %10s %10s %10s %10s %10s %10s %10s %11s\n" % heads
    end

    def self.format_account_money_lines(result)
      keys = ['posted_on', 'account_code', 'currency_code', 'segregation_code', 'kind', 'beginning_balance', 'charges']
      keys << ['adjustments', 'pnl_futures', 'ledger_balance', 'open_trade_equity', 'cash_account_balance']
      keys << ['net_liquidating_balance', 'currency_mark']
      keys = keys.flatten

      vals = []
      keys.each { |key| vals << result[key] }

      if result['currency_mark'].blank?
        line = "%10s %10s %3s %4s %4s %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f\n" % vals
      else
        line = "%10s %10s %3s %4s %4s %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f %10.2f %11.6f\n" % vals
      end

      line << "\n" if result['kind'] == 'BASE'
      line
    end

    def self.format_firm_open_positions_page_header
      "%10s %15s %15s %10s %12s %12s %12s %12s\n" % %W(Stated Set Claim Account Bot Sld Net OTE)
    end

    def self.format_firm_open_positions(result)
      keys = %W(stated_on claim_set_code claim_code account_code bot sld net ote)

      vals = []
      keys.each { |key| vals << result[key] }

      line = ''

      if result['claim_code'].blank? and result['account_code'].blank?
        line << "\n"
      else
        line << "%10s %15s %15s %10s %12s %12s %12s %12.2f\n" % vals
        line << "\n" if result['claim_code'].blank?
      end

      line
    end

    def self.format_daily_charges_by_account_page_header
      "%10s %10s %6s %3s %15s %12s %8s\n" % %W(Posted Account Charge CCY Set Amount Done)
    end

    def self.format_daily_charges_by_account(result)
      keys = %W(posted_on account_code chargeable_type_code currency_code claim_set_code amount done)

      #
      # todo this is a bit ugly
      #
      unless result['claim_set_code'].blank?
        a, b, c = result['claim_set_code'].split(':')
        result['claim_set_code'] = [a, b].join(':')
        result['done'] = c
      end

      vals = []
      keys.each { |key| vals << result[key] }

      if vals.first.blank?
        "\n"
      elsif result['currency_code'].blank? and result['claim_set_code'].blank?
        ''
      else
        line = "%10s %10s %6s %3s %15s %12.2f %8s\n" % vals
        line << "\n" if result['claim_set_code'].blank?
        line
      end
    end

    def self.format_daily_charges_by_exchange_page_header
      "%10s %10s %6s %3s %15s %12s %8s\n" % %W(Posted Exchange Charge CCY Set Amount Done)
    end

    def self.format_daily_charges_by_exchange(result)
      keys = %W(posted_on exchange_code chargeable_type_code currency_code claim_set_code amount done)

      #
      # todo this is a bit ugly
      #
      unless result['claim_set_code'].blank?
        a, b, c = result['claim_set_code'].split(':')
        result['claim_set_code'] = [a, b].join(':')
        result['done'] = c
      end

      vals = []
      keys.each { |key| vals << result[key] }

      if vals.first.blank?
        "\n"
      elsif result['currency_code'].blank? and result['claim_set_code'].blank?
        ''
      else
        line = "%10s %10s %6s %3s %15s %12.2f %8s\n" % vals
        line << "\n" if result['claim_set_code'].blank?
        line
      end
    end

    def self.format_monthly_charges_by_account_page_header
      "%10s %10s %6s %3s %15s %12s %8s\n" % %W(Posted Account Charge CCY Set Amount Done)
    end

    def self.format_monthly_charges_by_account(result)
      keys = %W(posted_on account_code chargeable_type_code currency_code claim_set_code amount done)

      vals = []
      keys.each { |key| vals << result[key] }

      if vals.first.blank?
        "\n"
      elsif result['currency_code'].blank? and result['claim_set_code'].blank?
        ''
      else
        line = "%10s %10s %6s %3s %15s %12.2f %8s\n" % vals
        line << "\n" if result['claim_set_code'].blank?
        line
      end
    end

    def self.format_monthly_charges_by_exchange_page_header
      "%10s %10s %6s %3s %15s %12s %8s\n" % %W(Posted Exchange Charge CCY Set Amount Done)
    end

    def self.format_monthly_charges_by_exchange(result)
      keys = %W(posted_on exchange_code chargeable_type_code currency_code claim_set_code amount done)

      vals = []
      keys.each { |key| vals << result[key] }

      if vals.first.blank?
        "\n"
      elsif result['currency_code'].blank? and result['claim_set_code'].blank?
        ''
      else
        line = "%10s %10s %6s %3s %15s %12.2f %8s\n" % vals
        line << "\n" if result['claim_set_code'].blank?
        line
      end
    end

    def self.format_realized_pnl_and_ote_day_mtd_ytd_page_header
      "%10s %8s %3s %12s %12s %12s\n" % %W(Period Exchange CCY PNL OTE Total)
    end

    def self.format_realized_pnl_and_ote_day_mtd_ytd(result)
      keys = %W(period exg_code ccy_code ccy_pnl ccy_ote ccy_total)

      vals = []
      keys.each { |key| vals << result[key] }

      if vals.first.blank?
        "\n"
      else
        "%10s %8s %3s %12.2f %12.2f %12.2f\n" % vals
      end
    end

    def self.query_account_money_lines(date)
      sql = "
        SELECT
            m.posted_on,
            a.code as account_code,
            c.code as currency_code,
            s.code as segregation_code,
            m.kind,
            m.beginning_balance,
            m.charges,
            m.adjustments,
            m.pnl_futures,
            m.ledger_balance,
            m.open_trade_equity,
            m.cash_account_balance,
            m.net_liquidating_balance,
            m.currency_mark
        FROM
            accounts a,
            currencies c,
            segregations s,
            money_lines m
        WHERE
            posted_on = \'#{date}\' AND
            a.id = m.account_id AND
            c.id = m.currency_id AND
            s.id = m.segregation_id
        ORDER BY
            a.code,
            m.kind DESC,
            a.code
      "
      ActiveRecord::Base.connection.execute(sql)
    end

    def self.query_firm_money_lines(date)
      sql = "
        SELECT
            m.posted_on,
            c.code AS currency_code,
            s.code AS segregation_code,
            m.kind,
            SUM(m.beginning_balance)       AS beginning_balance,
            SUM(m.charges)                 AS charges,
            SUM(m.adjustments)             AS adjustments,
            SUM(m.pnl_futures)             AS pnl_futures,
            SUM(m.ledger_balance)          AS ledger_balance,
            SUM(m.open_trade_equity)       AS open_trade_equity,
            SUM(m.cash_account_balance)    AS cash_account_balance,
            SUM(m.net_liquidating_balance) AS net_liquidating_balance,
            m.currency_mark
        FROM
            currencies c,
            segregations s,
            money_lines m
        WHERE
            posted_on = \'#{date}\' AND
            c.id = m.currency_id AND
            s.id = m.segregation_id
        GROUP BY
            m.posted_on,
            c.code,
            s.code ,
            m.kind,
            m.currency_mark
        ORDER BY
            c.code,
            m.kind DESC
      "
      ActiveRecord::Base.connection.execute(sql)
    end

    def self.query_firm_open_positions(date)
      sql = "
        SELECT
            stated_on,
            s.code AS claim_set_code,
            f.code AS claim_code,
            account_code,
            SUM(bot)::INTEGER AS bot,
            SUM(sld)::INTEGER AS sld,
            SUM(net)::INTEGER AS net,
            SUM(ote)          AS ote
        FROM
            claim_sets s,
            claim_futures_view f,
            statement_positions p
        WHERE
            stated_on = \'#{date}\' AND
            s.id = f.claim_set_id AND
            f.code = p.claim_code
        GROUP BY
            ROLLUP ( stated_on, claim_set_code, expires_on || ' ' || f.code, f.code, account_code)
        ORDER BY
            stated_on,
            claim_set_code,
            expires_on || ' ' || f.code,
            account_code
      "
      ActiveRecord::Base.connection.execute(sql)
    end

    def self.query_daily_charges_by_account(date)
      sql = "
        SELECT
            c.posted_on,
            c.account_code                    AS account_code,
            c.chargeable_type_code            AS chargeable_type_code,
            c.currency_code                   AS currency_code,
            c.claim_set_code || ':' || d.done AS claim_set_code,
            SUM(c.amount)                     AS amount
        FROM
            abs_done_by_account_and_claim_set_view d,
            net_charged_by_account_and_claim_set_view c
        WHERE
            c.posted_on = \'#{date}\' AND
            d.posted_on = c.posted_on AND
            d.account_code = c.account_code AND
            d.claim_set_code = c.claim_set_code
        GROUP BY
            ROLLUP (c.posted_on, c.account_code, c.chargeable_type_code, c.currency_code, c.claim_set_code || ':' || d.done )
        ORDER BY
            posted_on,
            account_code,
            chargeable_type_code,
            currency_code,
            claim_set_code
      "
      ActiveRecord::Base.connection.execute(sql)
    end

    def self.query_daily_charges_by_exchange(date)
      sql = "
        SELECT
            c.posted_on,
            split_part(c.claim_set_code, ':', 1) AS exchange_code,
            c.chargeable_type_code               AS chargeable_type_code,
            c.currency_code                      AS currency_code,
            c.claim_set_code || ':' || d.done    AS claim_set_code,
            SUM(c.amount)                        AS amount
        FROM
            abs_done_by_claim_set_view d,
            net_charged_by_claim_set_view c
        WHERE
            c.posted_on = \'#{date}\' AND
            d.posted_on = c.posted_on AND
            d.claim_set_code = c.claim_set_code
        GROUP BY
            ROLLUP (c.posted_on, split_part(c.claim_set_code, ':', 1), c.chargeable_type_code, c.currency_code, c.claim_set_code || ':' || d.done )
        ORDER BY
            posted_on,
            split_part(c.claim_set_code, ':', 1),
            chargeable_type_code,
            currency_code,
            c.claim_set_code || ':' || d.done
      "
      ActiveRecord::Base.connection.execute(sql)
    end

    def self.query_monthly_charges_by_account(date)
      sql = "
        SELECT
            TO_CHAR(c.posted_on, 'YYYY-MM') AS posted_on,
            c.account_code                  AS account_code,
            c.chargeable_type_code          AS chargeable_type_code,
            c.currency_code                 AS currency_code,
            c.claim_set_code                AS claim_set_code,
            SUM(c.amount)                   AS amount,
            SUM(d.done)                     AS done
        FROM
            abs_done_by_account_and_claim_set_view d,
            net_charged_by_account_and_claim_set_view c
        WHERE
            TO_CHAR(c.posted_on, 'YYYY-MM') = \'#{date.strftime('%Y-%m')}\' AND
            c.posted_on <= \'#{date}\' AND
            d.posted_on = c.posted_on AND
            d.account_code = c.account_code AND
            d.claim_set_code = c.claim_set_code
        GROUP BY
            ROLLUP (TO_CHAR(c.posted_on, 'YYYY-MM'), c.account_code, c.chargeable_type_code, c.currency_code, c.claim_set_code )
        ORDER BY
            TO_CHAR(c.posted_on, 'YYYY-MM'),
            account_code,
            chargeable_type_code,
            currency_code,
            claim_set_code
      "
      ActiveRecord::Base.connection.execute(sql)
    end

    def self.query_monthly_charges_by_exchange(date)
      sql = "
        SELECT
            TO_CHAR(c.posted_on, 'YYYY-MM')      AS posted_on,
            split_part(c.claim_set_code, ':', 1) AS exchange_code,
            c.chargeable_type_code               AS chargeable_type_code,
            c.currency_code                      AS currency_code,
            c.claim_set_code                     AS claim_set_code,
            SUM(c.amount)                        AS amount,
            SUM(d.done)                          AS done
        FROM
            abs_done_by_account_and_claim_set_view d,
            net_charged_by_account_and_claim_set_view c
        WHERE
            TO_CHAR(c.posted_on, 'YYYY-MM') = \'#{date.strftime('%Y-%m')}\' AND
            c.posted_on <= \'#{date}\' AND
            d.posted_on = c.posted_on AND
            d.account_code = c.account_code AND
            d.claim_set_code = c.claim_set_code
        GROUP BY
            ROLLUP (TO_CHAR(c.posted_on, 'YYYY-MM'), split_part(c.claim_set_code, ':', 1), c.chargeable_type_code, c.currency_code, c.claim_set_code )
        ORDER BY
            TO_CHAR(c.posted_on, 'YYYY-MM'),
            split_part(c.claim_set_code, ':', 1),
            chargeable_type_code,
            currency_code,
            claim_set_code
      "
      ActiveRecord::Base.connection.execute(sql)
    end

    def self.query_realized_pnl_and_ote_day_mtd_ytd(date)
      sql = "
        SELECT
            pnls.period,
            pnls.exg_code,
            pnls.currency_code AS ccy_code,
            pnls.ccy_pnl,
            CASE
                WHEN otes.ccy_ote IS NULL
                THEN 0
                ELSE otes.ccy_ote
            END AS ccy_ote,
            CASE
                WHEN otes.ccy_ote IS NULL
                THEN pnls.ccy_pnl
                ELSE pnls.ccy_pnl + otes.ccy_ote
            END AS ccy_total
        FROM
            (
             SELECT
                    TO_CHAR(posted_on, 'YYYY-MM-DD') AS period,
                    exg_code,
                    currency_code,
                    SUM(inc) AS ccy_pnl
               FROM
                    inc_by_exg_held
              WHERE
                    posted_on = \'#{date}\'
           GROUP BY
                    period,
                    exg_code,
                    currency_code
              UNION
             SELECT
                    TO_CHAR(posted_on, 'YYYY-MM') AS period,
                    exg_code,
                    currency_code,
                    SUM(inc) AS ccy_pnl
               FROM
                    inc_by_exg_held
              WHERE
                    posted_on <= \'#{date}\' AND
                    TO_CHAR(posted_on, 'YYYY-MM') = TO_CHAR(DATE \'#{date}\', 'YYYY-MM')
           GROUP BY
                    period,
                    exg_code,
                    currency_code
              UNION
             SELECT
                    TO_CHAR(posted_on, 'YYYY') AS period,
                    exg_code,
                    currency_code,
                    SUM(inc) AS ccy_pnl
               FROM
                    inc_by_exg_held
              WHERE
                    posted_on <= \'#{date}\' AND
                    TO_CHAR(posted_on, 'YYYY') = TO_CHAR(DATE \'#{date}\', 'YYYY')
           GROUP BY
                    period,
                    exg_code,
                    currency_code
           ORDER BY
                    period DESC,
                    exg_code,
                    currency_code) AS pnls
        LEFT JOIN
            (
             SELECT
                    *
               FROM
                    held_by_exg_ccy_otes
              WHERE
                    posted_on = \'#{date}\') AS otes
         ON
            pnls.exg_code || pnls.currency_code = otes.exg_code ||otes.currency_code
        ORDER BY
            period DESC,
            exg_code,
            ccy_code;
      "

      ActiveRecord::Base.connection.execute(sql)
    end

  end
end