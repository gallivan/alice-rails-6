module Builders

  class JournalEntryBuilder

    def self.build_for_adjustment(adjustment)
      journal = Journal.first # only one
      journal_entry_type = JournalEntryType.find_by_code('ADJ')
      JournalEntry.create! do |e|
        e.account_id = adjustment.account_id
        e.journal = journal
        e.journal_entry_type = journal_entry_type
        e.amount = adjustment.amount
        e.currency_id = adjustment.currency_id
        e.posted_on = adjustment.posted_on
        e.as_of_on = adjustment.posted_on
        e.memo = adjustment.memo
        e.segregation_id = adjustment.segregation_id
      end
    end

    def self.update_for_adjustment(adjustment)
      journal_entry = adjustment.journal_entry

      a_hash = adjustment.attributes
      a_hash.delete('adjustment_type_id')
      a_hash.delete('journal_entry_id')
      a_hash.delete('created_at')
      a_hash.delete('updated_at')

      e_hash = journal_entry.attributes
      e_hash.merge!(a_hash)
      e_hash.delete('id')
      e_hash[:as_of_on] = e_hash['posted_on']
      journal_entry.update_attributes!(e_hash)
    end

    def self.build_for_charge(charge)
      #
      # TODO SHOULD PROBABLY HAVE MULTIPLE JOURNALS.
      #
      journal = Journal.first

      code = charge.chargeable.chargeable_type.code.match(/BRK/) ? 'COM' : 'FEE'
      journal_entry_type = JournalEntryType.find_by_code(code)

      JournalEntry.create! do |e|
        e.account_id = charge.account_id
        e.journal_id = journal.id
        e.journal_entry_type_id = journal_entry_type.id
        e.memo = "ClaimSet #{charge.chargeable.claim_set.code}"
        e.amount = charge.amount
        e.currency_id = charge.currency_id
        e.posted_on = charge.posted_on
        e.as_of_on = charge.posted_on
        e.segregation_id = charge.segregation_id
      end
    end

    def self.build_for_pnl(pnl)
      claim = Claim.find(pnl['claim_id'])
      journal = Journal.first # only one
      journal_entry_type = JournalEntryType.find_by_code('PNL')
      JournalEntry.create! do |e|
        e.account_id = pnl['account_id']
        e.journal_id = journal.id
        e.journal_entry_type_id = journal_entry_type.id
        e.memo = "PNL for offset #{pnl['offset_id']}"
        e.amount = pnl['amount']
        e.currency_id = pnl['currency_id']
        e.posted_on = pnl['posted_on']
        e.as_of_on = pnl['posted_on']
        e.segregation_id = Segregation.for_claim(claim).id
      end
    end

    def self.build_for_ote(position, business_date)
      journal = Journal.first # only one
      journal_entry_type = JournalEntryType.find_by_code('OTE')
      JournalEntry.create! do |e|
        e.account_id = position.account_id
        e.journal = journal
        e.journal_entry_type = journal_entry_type
        e.memo = "OTE for position #{position.id}"
        e.amount = position.ote
        e.currency_id = position.currency_id
        e.posted_on = business_date
        e.as_of_on = business_date
        e.segregation = Segregation.for_position(position)
      end
    end

    def self.reverse(entry, posting_date)
      attributes = entry.attributes
      attributes[:posted_on] = posting_date
      attributes[:amount] = entry.amount * -1
      attributes[:memo] = "Reversed #{entry.id}"
      attributes[:id] = nil
      JournalEntry.create!(attributes)
    end

  end
end