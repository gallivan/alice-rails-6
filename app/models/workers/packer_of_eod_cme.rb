module Workers
  class PackerOfEodCme < Packer

    def pack(picker_report)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      Rails.logger.info picker_report.id
      hash = self.cme_fixml_to_hash(picker_report[:data])
      report = build_report(hash, 'EOD_CME')
      hash[:packer_report_id] = report.id
      hash[:root] = 'EOD_CME'

      Rails.logger.info("Packer: TODO handling PackerReport #{report.id}")
      puts "PackerReport: #{report.id}"

      packed = Workers::Normalizer.normalize_cme_eod(hash)
      report.update(:fate, 'DONE')
      packed
    rescue Exception => e
      report.updates(fate: 'FAIL', goof_error: e.message, goof_trace: e.backtrace)
      msg = "Packer.pack handling of message failed with #{e}"
      Rails.logger.warn msg
      e.backtrace_locations.each do |location|
        Rails.logger.warn location
      end
    end

  end
end
