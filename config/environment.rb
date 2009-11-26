# Be sure to restart your server when you modify this file

# Specifies gem version of Rails to use when vendor/rails is not present
RAILS_GEM_VERSION = '2.3.4' unless defined? RAILS_GEM_VERSION

# Bootstrap the Rails environment, frameworks, and default configuration
require File.join(File.dirname(__FILE__), 'boot')

Rails::Initializer.run do |config|
  
  config.gem "formtastic"
  config.gem 'authlogic'
  config.gem 'aasm'
  config.gem 'yaroslav-russian', :lib => 'russian'  
  config.gem 'daemons'
  config.gem 'nokogiri'
  config.time_zone = 'UTC'

  config.i18n.load_path += Dir[File.join(RAILS_ROOT, 'config', 'locales', '**', '*.{rb,yml}')]   
  config.i18n.default_locale = :ru
end


unless RAILS_ENV == 'production'
  ActiveMerchant::Billing::Base.mode = :test
  ActiveMerchant::Billing::Base.gateway_mode = :test
  ActiveMerchant::Billing::Base.integration_mode = :test
end
  ActiveMerchant::Billing::PaypalGateway.pem_file =  File.read(File.join(RAILS_ROOT,'lib/gateway/paypal/cert/paypal_cert.pem'))  



