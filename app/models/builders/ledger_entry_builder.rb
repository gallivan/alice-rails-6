module Builders

  class LedgerEntryBuilder

    def self.build(account, posted_on, ledger_entry_type, memo, amount, currency_id, segregation_id)
      ledger = Ledger.first

      ledger_entry = LedgerEntry.create! do |e|
        e.account = account
        e.ledger = ledger
        e.ledger_entry_type = ledger_entry_type
        e.memo = memo
        e.amount = amount
        e.currency_id = currency_id
        e.posted_on = posted_on
        e.as_of_on = posted_on
        e.segregation_id = segregation_id
      end

      ledger_entry
    end

  end
end