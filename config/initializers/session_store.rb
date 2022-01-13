# Be sure to restart your server when you modify this file.

# https://www.skcript.com/svr/samesite-issue-with-rails-in-chrome/
Rails.application.config.session_store :cookie_store, {
  :key => '_alice_session',
  :domain => :all,
  :same_site => :none,
  :secure => :true,
  :tld_length => 2
}