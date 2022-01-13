require "bunny"

module Workers
  class Packer

    def fix2hash(payload)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      list = payload.chop.split("\x01")
      hash = {}
      list.each do |element|
        key, val = element.split('=')
        hash[key] = val
      end
      hash
    end

    def cme_fixml_to_hash(payload)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      Hash.from_xml(payload)
    end

    def build_report(params, root)
      Rails.logger.info "Calling #{self.class}##{__method__}"
      PackerReport.create! do |r|
        r.root = root unless root.blank?
        r.kind = 'FILL'
        r.fate = 'TODO'
        r.data = params
        r.posted_on = Date.today
      end
    end

  end
end