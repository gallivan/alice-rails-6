class StatementMailer < ApplicationMailer

  default :from => "jackijack@eaglemarketmakers.com",
          :content_type => 'multipart/alternative',
          :parts_order => ["text/html", "text/enriched", "text/plain", "application/pdf"]

  TESTING_MAILING_LIST = "jackijack@eaglemarketmakers.com, lewis@eaglemarketmakers.com"

  if Rails.env['production']
    LARGE_TRADER_MAILING_LIST = "jackijack@eaglemarketmakers.com, backoffice@eaglemarketmakers.com"
    LARGE_TRADER_ERR_LIST = "jackijack@eaglemarketmakers.com"
    TO = "jackijack@eaglemarketmakers.com"
  else
    LARGE_TRADER_ERR_LIST = "jackijack@eaglemarketmakers.com"
    LARGE_TRADER_MAILING_LIST = "jackijack@eaglemarketmakers.com, backoffice@eaglemarketmakers.com"
    TO = "jackijack@eaglemarketmakers.com"
  end

  # https://launchschool.com/blog/handling-emails-in-rails

  def send_statement(base, account, date)
    begin
      filename = account.build_filename(base, date, 'pdf')

      unless File.exist? filename
        msg = "Missing #{filename} for #{__method__}. Skipping."
        EodMailer.alert(msg).deliver_now
        return
      end

      basename = Pathname.new(filename).basename.to_s
      attachments[basename] = {:mime_type => 'application/pdf', :content => File.read(filename)}

      @report_info = "Statement for #{account.code} posted on #{date} (#{base})"

      if Rails.env.production?
        user_emails = account.users.map {|user| user.email}.join(', ')
        @content = "Please report any issues or anomalies to your Back Office manager."
      else
        user_emails = TESTING_MAILING_LIST
        @content = "List of emails the report belongs to: " + user_emails
      end

      to_list = user_emails + ', ' + TESTING_MAILING_LIST

      mail(:to => to_list, :subject => @report_info)
    rescue Exception => e
      Rails.logger.warn("Email to #{user_emails} not sent: #{e.message}")
    end
  end

end
