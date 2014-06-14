Devise.setup do |config|
  config.secret_key = ENV["SECRET_KEY"] || "CHANGE_ME"

  config.mailer_sender = ENV["DEVISE_FROM_EMAIL"]

  require 'devise/orm/mongoid'

  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]
  config.stretches = Rails.env.test? ? 1 : 10
  config.reconfirmable = true
  config.password_length = 8..128
  config.reset_password_within = 6.hours
  config.sign_out_via = :get

  require 'omniauth-google-oauth2'

  config.omniauth(
    :google_oauth2,
    ENV["GOOGLE_CLIENT_ID"],
    ENV["GOOGLE_CLIENT_SECRET"],
    { access_type: "offline", approval_prompt: "", hd: ENV["GOOGLE_DOMAIN"] }
  )

  config.omniauth(
    :github,
    ENV["GITHUB_CLIENT_ID"],
    ENV["GITHUB_CLIENT_SECRET"],
    { scope: '' }
  )
end
