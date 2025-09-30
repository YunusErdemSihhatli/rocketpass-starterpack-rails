Devise.setup do |config|
  config.mailer_sender = "no-reply@rocketpass.local"

  require "devise/orm/active_record"

  # Use the application secret key base as JWT secret
  jwt_secret = Rails.application.secret_key_base

  config.jwt do |jwt|
    jwt.secret = jwt_secret
    jwt.dispatch_requests = [
      ["POST", %r{^/api/v1/auth/sign_in$}],
      ["POST", %r{^/api/v1/auth$}] # registrations#create
    ]
    jwt.revocation_requests = [
      ["DELETE", %r{^/api/v1/auth/sign_out$}]
    ]
    jwt.expiration_time = 15.minutes.to_i
    jwt.request_formats = { user: [:json] }
  end
end

