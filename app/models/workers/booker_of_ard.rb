module Workers
  class BookerOfArd < Booker

    def book(norm)
      report = build_report(norm)
      norm[:booker_report_id] = report.id

      puts '*'* 100
      puts norm

      Rails.logger.info("Booker: TODO handling BookerReport #{report.id}")
      puts "BookerReport: #{report.id}"

      begin

        fill = Builders::DealLegFillBuilder.build_from_ard(norm)
        position = Builders::PositionBuilder.build_or_update(fill)
        fill.update(position_id: position.id)

        report.update(:fate, 'DONE')
      rescue Exception => e
        puts "Booker: #{e.message}"
        report.updates(fate: 'FAIL', goof_error: e.message, goof_trace: e.backtrace)
        Rails.logger.warn "Booker: #{e.message} #{e.backtrace}"
        e.backtrace_locations.each do |location|
          Rails.logger.warn location
        end
      end
    end

    def build_report(params)
      BookerReport.create! do |r|
        r.root = params[:root] unless params[:root].blank?
        r.kind = 'FILL'
        r.fate = 'TODO'
        r.data = params
        r.posted_on = params[:posted_on]
      end
    end

    def rebook_by_date_and_fate(date, fate)
      # BookerReport.where(fate: fate, posted_on: date).order(:id).each do |report|
      #   norm = eval(report.data)
      #   norm[:booker_report_id] = report.id
      #   Rails.logger.info("Booker: TODO handling BookerReport #{report.id}")
      #   puts "BookerReport: #{report.id}"
      #   begin
      #     account = Account.find(norm[:account_id])
      #     account.handle_fill(norm)
      #     report.update(:fate, 'DONE')
      #   rescue Exception => e
      #     puts "Booker: #{e.message}"
      #     Rails.logger.warn "Booker: #{e.message} #{e.backtrace}"
      #     e.backtrace_locations.each do |location|
      #       Rails.logger.warn location
      #     end
      #   end
      # end
    end

  end
end