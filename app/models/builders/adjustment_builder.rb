module Builders

  class AdjustmentBuilder

    def self.build(params)
      adjustment = Adjustment.new do |a|
        a.account_id = params[:account_id]
        a.currency_id = params[:currency_id]
        a.adjustment_type_id = params[:adjustment_type_id]
        a.amount = params[:amount]
        a.posted_on = Date.parse(params[:posted_on])
        a.memo = params[:memo]
        a.segregation_id = params[:segregation_id]
      end
      journal_entry = JournalEntryBuilder.build_for_adjustment(adjustment)
      adjustment.update({journal_entry_id: journal_entry.id})
      adjustment.save!
      adjustment
    end

    def self.update(params)

      puts '.' * 100
      puts 'create'
      puts params
      puts '.' * 100

      adjustment = Adjustment.find(params[:id])
      hash = adjustment.attributes
      hash.merge!(params)
      adjustment.update!(hash)
      Builders::JournalEntryBuilder.update_for_adjustment(adjustment)
      adjustment
    end

    def self.destroy(params)
      adjustment = Adjustment.find(params[:id])
      journal_entry = adjustment.journal_entry
      adjustment.destroy
      journal_entry.destroy
      adjustment
    end

  end
end