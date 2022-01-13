class EodMailer < ApplicationMailer

  # https://launchschool.com/blog/handling-emails-in-rails

  TO = %w[8479224584@vtext.com 3124371934@tmomail.net 6302405208@txt.att.net jay.gallivan@gmail.com mjk122@att.net]

  TO_NON_PRD = %w[8479224584@vtext.com 6302405208@txt.att.net jay.gallivan@gmail.com]

  ENV_CODE = {
      production: 'PRD',
      staging: 'STG',
      integration: 'INT',
      development: 'DEV'
  }

  def env_code
    Rails.env.production
  end

  def status(message)
    begin
      @message = message
      to = Rails.env.production? ? TO : TO_NON_PRD
      mail(to: to, subject: "EOD #{ENV_CODE[Rails.env.to_sym]} status")
    rescue Exception => e
      Rails.logger.warn "Exception while emailing status: #{e.message}"
    end
  end

  def alert(message)
    begin
      @message = message
      to = Rails.env.production? ? TO : TO_NON_PRD
      mail(to: to, subject: "EOD #{ENV_CODE[Rails.env.to_sym]} ALERT")
    rescue Exception => e
      Rails.logger.warn "Exception while emailing alert: #{e.message}"
    end
  end

  def open_positions_alert(message)
    begin
      @message = message
      to = Rails.env.production? ? TO : TO_NON_PRD
      mail(to: to, subject: "EOD #{ENV_CODE[Rails.env.to_sym]} OPEN POSITIONS IN EXPIRED CLAIMS. EOD EXITED.")
    rescue Exception => e
      Rails.logger.warn "Exception while emailing open_positions_alert: #{e.message}"
    end
  end

end

