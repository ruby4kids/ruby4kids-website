Devise.setup do |config|

  require 'devise/orm/active_record'

  config.authentication_keys  = [:email]
  config.mailer_sender        = 'noreply@ruby4kids.com'
  config.http_authenticatable = false
  config.pepper               = "ea9f1901456e5e1212f3def6d61875d1cfdeb56d75ecaab2996ef708645e5ac115586cab70ebce639d054aec8526cc485f5f1f5535d00682e41fbf4e7a47547d"
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

  if Rails.env.production?
    config.omniauth :facebook, '122709084461490', 'dea95ce9b7240d8ebbe4a0b4bdd20021'
  else
    config.omniauth :facebook, '179167628772831', '1efb88826315bb44d30985aef813edd2'
  end

end
