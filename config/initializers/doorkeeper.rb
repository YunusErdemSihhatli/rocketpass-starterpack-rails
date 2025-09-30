Doorkeeper.configure do
  orm :active_record

  api_only

  resource_owner_from_credentials do |_routes|
    user = User.find_by(email: params[:username])
    if user&.valid_password?(params[:password])
      user
    end
  end

  resource_owner_authenticator do
    current_user || warden.authenticate!(scope: :user)
  end

  # Optional default scopes
  default_scopes :public
  optional_scopes :read, :write, :admin

  # Access token TTL
  access_token_expires_in 15.minutes

  # Use refresh tokens
  use_refresh_token

  # Enforce access token to be used for public API
  base_controller 'ActionController::API'
end

