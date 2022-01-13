require "bunny"

module Workers
  class Booker

    def book(packed)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      report = build_report(packed)
      packed[:booker_report_id] = report.id
      Rails.logger.info("#{self.class}##{__method__} handling BookerReport #{report.id}")
      begin
        account = Rails.cache.fetch("account:#{packed[:account_id]}") {Account.find(packed[:account_id]) }
        account.handle_fill(packed)
        report.update_attribute(:fate, 'DONE')
      rescue Exception => e
        puts "Booker: #{e.message}"
        Rails.logger.warn "Booker: #{e.message} #{e.backtrace}"
        e.backtrace_locations.each do |location|
          Rails.logger.warn location
        end
      end
    end

    # def book
    #   conn = conn = Bunny.new( :user => "alice", :password => ENV['ALICE_RABBITMQ_PWD'])
    #   conn.start
    #
    #   c = conn.create_channel
    #   q = c.queue(@i_queue, :durable => true, :auto_delete => false)
    #   x = c.fanout(@i_queue, :durable => true)
    #   q.bind(x)
    #
    #   q.subscribe(:manual_ack => true, :block => true) do |delivery_info, metadata, body|
    #     norm = JSON.parse(body)
    #     norm = Hash[norm.map { |k, v| [k.to_sym, v] }]
    #
    #     report = build_report(norm)
    #     norm[:booker_report_id] = report.id
    #
    #     Rails.logger.info("Booker: TODO handling BookerReport #{report.id}")
    #     puts "BookerReport: #{report.id}"
    #
    #     begin
    #       account = Rails.cache.fetch("account:#{norm[:account_id]}") { Account.find(norm[:account_id]) }
    #       account.handle_fill(norm)
    #       c.ack(delivery_info.delivery_tag)
    #       report.update_attribute(:fate, 'DONE')
    #     rescue Exception => e
    #       c.reject(delivery_info.delivery_tag)
    #       puts "Booker: #{e.message}"
    #       Rails.logger.warn "Booker: #{e.message} #{e.backtrace}"
    #       e.backtrace_locations.each do |location|
    #         Rails.logger.warn location
    #       end
    #     end
    #   end
    # end

    def build_report(params)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      BookerReport.create! do |r|
        r.root = params[:root] unless params[:root].blank?
        r.kind = 'FILL'
        r.fate = 'TODO'
        r.data = params
        r.posted_on = params[:posted_on]
      end
    end

    def rebook_by_date_and_fate(date, fate)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      BookerReport.where(fate: fate, posted_on: date).order(:id).each do |report|
        norm = eval(report.data)
        norm[:booker_report_id] = report.id
        Rails.logger.info("Booker: TODO handling BookerReport #{report.id}")
        puts "BookerReport: #{report.id}"
        begin
          account = Account.find(norm[:account_id])
          account.handle_fill(norm)
          report.update_attribute(:fate, 'DONE')
        rescue Exception => e
          puts "Booker: #{e.message}"
          Rails.logger.warn "Booker: #{e.message} #{e.backtrace}"
          e.backtrace_locations.each do |location|
            Rails.logger.warn location
          end
        end
      end
    end

  end
end