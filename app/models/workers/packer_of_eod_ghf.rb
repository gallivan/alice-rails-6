module Workers
  class PackerOfEodGhf < Packer

    def pack(picker_report)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      packed = []
      tag = 'EOD_GHF'
      hash = {}
      hash[:csv] = picker_report
      hash[:root] = tag
      report = build_report(hash, tag)
      hash[:packer_report_id] = report.id
      Rails.logger.info("Packer: TODO handling PackerReport #{report.id}")
      puts "PackerReport: #{report.id}"
      packed << Workers::Normalizer.normalize_eod_ghf_csv(hash)
      report.update(:fate, 'DONE')
      packed
    end

  end
end