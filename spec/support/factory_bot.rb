require 'factory_bot'
RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods
  require "#{Rails.root}/config/initializers/factory_bot_find_or_create.rb"
end