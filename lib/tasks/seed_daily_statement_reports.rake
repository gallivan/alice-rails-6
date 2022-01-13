task :seed_daily_statement_reports => :environment do

  report_type_code = 'daily_account_statement'

  report_type = ReportType.find_by_code(report_type_code)

  if report_type.blank?
    report_type = ReportType.create! do |t|
      t.code = report_type_code
      t.name = report_type_code
    end
  end

  formats = %W(PDF TXT)

  formats.each do |format|
    format_type = FormatType.find_by_code(format)

    base_dir_name = ENV[[format, 'DIR'].join('_')]
    dates = Dir.entries(base_dir_name).reject { |entry| entry =~ /^\.{1,2}$/ }

    dates.sort.each do |date|
      dir_name = [base_dir_name, date].join('/')

      file_names = Dir.entries(dir_name).reject { |entry| entry =~ /^\.{1,2}$/ }
      file_names = file_names.reject { |entry| entry !~ /^daily_account_statement/ }

      file_names.sort.each do |file_name|
        location = [dir_name, file_name].join('/')
        puts location

        if StatementMoneyLine.stated_on(Date.parse(date)).blank?
          puts "Deleting #{location}"
          File.unlink(location) if File.exists?(location)
        end

        begin
          report = Report.find_by_location(location)
          report.delete unless report.blank?

          params = {
              posted_on: date,
              format_type_code: format_type.code,
              report_type_code: report_type.code,
              memo: file_name,
              location: location
          }
          Builders::ReportBuilder.build(params)
        rescue Exception => e
          puts e.message
        end
      end

    end
  end

end

