module Workers
  class Picker

    TRDCAPT_REGEX = /<TrdCaptRpt.+<\/TrdCaptRpt>/m
    POSRPT_REGEX = /<PosRpt.+<\/PosRpt>/m

    # attr_reader :connections

    FILE_WAIT_INTERVAL = 5.minutes

    def build_report(message, kind, posted_on)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      PickerReport.create! do |r|
        r.kind = kind
        r.fate = 'TODO'
        r.data = message.inspect
        r.posted_on = posted_on
      end
    end

    def pick_file
      Rails.logger.info "Calling #{self.class}##{__method__}"
      conn = conn = Bunny.new(:user => "alice", :password => ENV['ALICE_RABBITMQ_PWD'])
      conn.start

      ch = conn.create_channel
      q = ch.queue("itd.abn.picked.all", :durable => true, :auto_delete => false)
      x = ch.fanout("itd.abn.picked.all", :durable => true)
      q.bind(x)

      seq_num = 0

      filename = Rails.root + 'etc/data/aacc/FIX.4.2-EAGLE_MARKET_MAKERS-AACC.messages.log'

      File.open(filename).each do |line|
        seq_num += 1
        x.publish(line.chop, :routing_key => q.name)
        sleep 0.001
      end

      sleep 1.0
      conn.close
    end

    # def send_messages(messages, destination, posted_on, kind)
    #   conn = conn = Bunny.new(:user => "alice", :password => ENV['ALICE_RABBITMQ_PWD'])
    #   conn.start
    #
    #   c = conn.create_channel
    #   q = c.queue(destination, :durable => true, :auto_delete => false)
    #   x = c.fanout(destination, :durable => true)
    #   q.bind(x)
    #
    #   messages.each do |message|
    #     report = build_report_eod_cme(message, kind, posted_on)
    #
    #     begin
    #       Rails.logger.info("Picker: TODO handling PickerReport #{report.id}")
    #       puts "PickerReport: #{report.id}"
    #       x.publish(message, :routing_key => q.name)
    #       report.update(:fate, 'DONE')
    #       Rails.logger.info("Picker: DONE handling PickerReport #{report.id}")
    #     rescue Exception => e
    #       Rails.logger.info("Picker: FAIL handling PickerReport #{report.id}")
    #       report.updates(fate: 'FAIL', goof_error: e.message, goof_trace: e.backtrace)
    #     end
    #
    #     sleep 0.001
    #   end
    #
    #   conn.close
    # end

    private

    def cln_file(filename)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      puts 'cln_file'
      Rails.logger.info "Deleting #{filename}"
      File.delete(filename)
    end

    def prepare_line(line)
      '<?xml version="1.0" encoding="UTF-8"?><FIXML>' + line.gsub(/\n/, "") + "</FIXML>"
    end

    # def load_lines(lines)
    #   puts 'load_lines'
    #   lines.each do |line|
    #     line = prepare_line(line)
    #     PickerReport.create! do |r|
    #       r.root = 'EOD_CME'
    #       r.kind = 'EOD_CME'
    #       r.fate = 'TODO'
    #       r.data = line
    #       r.posted_on = Date.today
    #     end
    #   end
    #   lines.clear
    # end

    def remove_file(filename)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      puts 'remove_file'
      Rails.logger.info "Removing #{ENV['DNL_DIR']}/#{filename}"
      File.delete("#{ENV['DNL_DIR']}/#{filename}")
    end

  end
end