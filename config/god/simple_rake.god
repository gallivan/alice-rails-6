if `whoami` == 'alice'
  rails_env = ENV['RAILS_ENV'] = 'production'
  rails_root = ENV['RAILS_ROOT'] || "#{ENV['HOME']}/www/alice/current"
else
  rails_env = ENV['RAILS_ENV'] = 'development'
  rails_root = ENV['RAILS_ROOT'] || "#{ENV['HOME']}/ruby-projects/alice"
end

ENV['PATH']     = "#{ENV['HOME']}/.rvm/gems/ruby-2.2.2@rails423/bin:#{ENV['HOME']}/.rvm/gems/ruby-2.2.2@global/bin:#{ENV['HOME']}/.rvm/rubies/ruby-2.2.2/bin:/usr/bin:/bin:$PATH"
ENV['GEM_PATH'] = "#{ENV['HOME']}/.rvm/gems/ruby-2.2.2@rails423:#{ENV['HOME']}/.rvm/gems/ruby-2.2.2@global"
ENV['GEM_HOME'] = "#{ENV['HOME']}/.rvm/gems/ruby-2.2.2@rails423"

ENV['MY_RUBY_HOME'] = "#{ENV['HOME']}/.rvm/rubies/ruby-2.2.2"
ENV['IRBRC'] = "#{ENV['HOME']}/.rvm/rubies/ruby-2.2.2/.irbrc"
ENV['RUBY_VERSION'] = 'ruby-2.2.2'

ENV['sendgridusername'] = 'jay.gallivan@gmail.com'
ENV['sendgridpassword'] = `cat ~/.sendgrid_pwd`
ENV['QUANDL_API_KEY'] = `cat ~/.quandl_api_key`

ENV['TXT_DIR'] = "#{ENV['HOME']}/var/txt"
ENV['PDF_DIR'] = "#{ENV['HOME']}/var/pdf"
ENV['DNL_DIR'] = "#{ENV['HOME']}/var/dnl"
ENV['LRG_DIR'] = "#{ENV['HOME']}/var/lrg"

God.watch do |w|
  w.dir = "#{rails_root}/lib/tasks"
  jobname = "#{rails_root}/lib/tasks/simple.rake"
  w.name = File.basename(jobname, ".*")
  w.log = "#{rails_root}/log/#{w.name}.log"
  # w.start = "rake --rakefile #{jobname} #{w.name}"
  w.start = "rake simple"
  w.keepalive
end
