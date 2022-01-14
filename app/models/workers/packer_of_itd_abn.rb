module Workers
  class PackerOfItdAbn < Packer

    def initialize(i_queue, o_queue)
      @i_queue = i_queue
      @o_queue = o_queue
    end

    #
    # reads fm a 'picked' queue
    # builds PackerReport
    # sends to a 'packed' queue
    #

    def pack
      conn_aacc = conn = Bunny.new(:user => "alice", :password => ENV['ALICE_RABBITMQ_PWD'])
      conn_aacc.start
      chnl_aacc = conn_aacc.create_channel

      q_aacc = chnl_aacc.queue(@i_queue, :durable => true, :auto_delete => false)
      x_aacc = chnl_aacc.fanout(@i_queue, :durable => true)
      q_aacc.bind(x_aacc)

      conn_norm = conn = Bunny.new(:user => "alice", :password => ENV['ALICE_RABBITMQ_PWD'])
      conn_norm.start
      chnl_norm = conn_norm.create_channel

      q_norm = chnl_norm.queue(@o_queue, :durable => true, :auto_delete => false)
      x_norm = chnl_norm.fanout(@o_queue, :durable => true)
      q_norm.bind(x_norm)

      q_aacc.subscribe(:manual_ack => true, :block => true) do |delivery_info, metadata, body|
        begin
          tag = 'ITD_ABN'

          hash = {}
          hash[:csv] = body
          hash[:root] = tag

          report = build_report(hash, tag)
          hash[:packer_report_id] = report.id

          Rails.logger.info("Packer: TODO handling PackerReport #{report.id}")
          puts "PackerReport: #{report.id}"

          norm = Workers::Normalizer.normalize_itd_abn_csv(hash)
          x_norm.publish(norm.to_json, :routing_key => q_norm.name)

          chnl_aacc.ack(delivery_info.delivery_tag)
          report.update(:fate, 'DONE')
        rescue Exception => e
          chnl_aacc.reject(delivery_info.delivery_tag)
          report.updates(fate: 'FAIL', goof_error: e.message, goof_trace: e.backtrace)
          msg = "Packer.pack handling of message failed with #{e}"
          Rails.logger.warn msg
          e.backtrace_locations.each do |location|
            Rails.logger.warn location
          end
        end
      end
    end

  end
end