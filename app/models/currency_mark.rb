# == Schema Information
#
# Table name: currency_marks
#
#  id          :integer          not null, primary key
#  currency_id :integer
#  posted_on   :date
#  mark        :decimal(, )
#  created_at  :datetime         not null
#  updated_at  :datetime         not null
#

class CurrencyMark < ApplicationRecord
  validates :currency_id, presence: true
  validates :posted_on, presence: true
  validates :mark, presence: true

  belongs_to :currency

  scope :for_ccy, -> (currency_id) {where(currency_id: currency_id)}
  scope :posted_on, -> (posted_on) {where(posted_on: posted_on)}

  def self.post_mark(params)
    filter = params.select {|key, val| key.to_s.match(/^(currency_id|posted_on)$/)}
    rate = CurrencyMark.where(filter).first
    if rate.blank?
      create! do |m|
        m.currency_id = params[:currency_id]
        m.posted_on = params[:posted_on]
        m.mark = params[:mark]
      end
    else
      rate.update(:mark, params[:mark])
    end
  end

  def self.set_fx_rates(date, source)
    if source.match('Quandl')
      set_quandl_marks(date)
    elsif source.match('OpenExchange')
      self.set_open_exhcange_marks(date)
    else
      EodMailer.alert("FX rates source unknown or not set. Using Quandl.").deliver_now
      set_quandl_marks(date)
    end
  end

  def self.set_quandl_marks(date)
    puts "Getting currency from Quandl for #{date}"
    rates = Workers::QuandlDAO.fx_rates
    book(date, rates)
  end

  def self.set_open_exhcange_marks(date)
    fx = OpenExchangeRates::Rates.new
    rates = {'USD' => 1.0}
    Currency.order(:code).each do |c|
      next if c.code.match(/UKN/)
      begin
        rates[c.code] = fx.exchange_rate(from: c.code, to: "USD")
      rescue Exception => e
        EodMailer.alert("Open Exchange Service Exception: #{e.message}. Retrying in 5 seconds.").deliver_now
        sleep 5
        retry
      end
    end
    book(date, rates)
  end

  def self.book(date, rates)
    rates.keys.each do |key|
      Rails.logger.info "FX RATE FOR: #{key} #{rates[key]}"
      begin
        currency = Currency.find_by_code(key)
        next if currency.blank?
        mark = CurrencyMark.where(currency_id: currency.id, posted_on: date).first
        puts "Posting mark for #{currency.code} of #{rates[key]}"
        if mark.blank?
          CurrencyMark.create! do |m|
            m.currency_id = currency.id
            m.posted_on = date
            m.mark = rates[key]
          end
        else
          mark.update(:mark, rates[key])
        end
      rescue Exception => e
        Rails.logger.warn e.message
      end
    end
  end

end
