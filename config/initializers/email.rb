# Load mail configuration if not in test environment
require 'smtp-tls'
if RAILS_ENV != 'test'
  email_settings = YAML::load(File.open("#{RAILS_ROOT}/config/email.yml"))
  ActionMailer::Base.delivery_method = :smtp
  ActionMailer::Base.smtp_settings = email_settings[RAILS_ENV] unless email_settings[RAILS_ENV].nil?
end
