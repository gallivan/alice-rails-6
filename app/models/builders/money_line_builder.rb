module Builders

  class MoneyLineBuilder

    def self.build(ledger_entry)
      type_code = ledger_entry.ledger_entry_type.code

      posted_on = ledger_entry.posted_on
      account_id = ledger_entry.account_id
      currency_id = ledger_entry.currency_id
      segregation_id = ledger_entry.segregation_id

      money_line = MoneyLine.for_account(account_id).currency(currency_id).segregation(segregation_id).posted_on(posted_on).first

      if money_line.blank?
        money_line = MoneyLine.create! do |m|
          m.kind = 'HELD'
          m.posted_on = posted_on
          m.account_id = account_id
          m.currency_id = currency_id
          m.currency_mark = CurrencyMark.for_ccy(currency_id).posted_on(posted_on).first.mark
          m.segregation_id = ledger_entry.segregation_id
        end
      end

      money_line.update_attribute(:beginning_balance, ledger_entry.amount) if type_code == 'BEG'
      money_line.update_attribute(:cash_account_balance, ledger_entry.amount) if type_code == 'CSHACT'
      money_line.update_attribute(:charges, ledger_entry.amount) if type_code == 'CHG'
      money_line.update_attribute(:adjustments, ledger_entry.amount) if type_code == 'ADJ'
      money_line.update_attribute(:pnl_futures, ledger_entry.amount) if type_code == 'PNLFUT'
      money_line.update_attribute(:ledger_balance, ledger_entry.amount) if type_code == 'LEG'
      money_line.update_attribute(:open_trade_equity, ledger_entry.amount) if type_code == 'OTE'
      money_line.update_attribute(:net_liquidating_balance, ledger_entry.amount) if type_code == 'LIQ'

      money_line
    end

  end

end
