Devise.setup do |config|

  require 'devise/orm/active_record'

  config.authentication_keys  = [:login]
  config.mailer_sender        = 'noreply@integrisati.com' # TODO: YAML-configurable
  config.http_authenticatable = false
  config.pepper               = File.read(File.expand_path('../../secrets/devise_pepper', __FILE__)) || ENV['INTEGRISATI_DEVISE_PEPPER']
  config.stretches            = 10
  config.remember_for         = 2.weeks
  config.password_length      = 6..20
  config.email_regexp         = /^([\w\!\#$\%\&\'\*\+\-\/\=\?\^\`{\|\}\~]+\.)*[\w\!\#$\%\&\'\*\+\-\/\=\?\^\`{\|\}\~]+@((((([a-z0-9]{1}[a-z0-9\-]{0,62}[a-z0-9]{1})|[a-z])\.)+[a-z]{2,6})|(\d{1,3}\.){3}\d{1,3}(\:\d{1,5})?)$/i
  config.lock_strategy        = :failed_attempts
  config.unlock_strategy      = :both
  config.maximum_attempts     = 20
  config.unlock_in            = 1.hour
  config.scoped_views         = true
  config.default_scope        = :user
  config.navigational_formats = [:html]

end
