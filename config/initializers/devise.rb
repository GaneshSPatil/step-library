Devise.setup do |config|
  #Replace example.com with your own domain name
  config.mailer_sender = 'mailer@example.com'

  require 'devise/orm/active_record'
  config.case_insensitive_keys = [ :email ]
  config.strip_whitespace_keys = [ :email ]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 10
  config.reconfirmable = true
  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 8..128
  config.reset_password_within = 6.hours
  config.sign_out_via = :delete
  config.secret_key = 'eb3a3439152e7adee8b45caf0374082ce08c10f7b5adc74b5c4c2ed5118d0dc1598cc32716974410f487c80a1410867e0242c1548a47bd2ff7a4c2c67a3e8201'

  #Add your ID and secret here
  #ID first, secret second
  config.omniauth :facebook, Rails.application.config.app_id, Rails.application.config.app_secret_key
end