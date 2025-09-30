module Api
  module V1
    class TokensController < ActionController::API
      include Pundit::Authorization

      respond_to :json
      skip_before_action :verify_authenticity_token

      def refresh
        raw = params.require(:refresh_token)
        token = RefreshToken.active.find_by_raw(raw)
        return render json: { error: 'invalid_refresh_token' }, status: :unauthorized unless token

        user = token.user

        # Rotate refresh token
        token.revoke!
        _new_record, new_refresh_token = RefreshToken.generate_for!(
          user,
          user_agent: request.user_agent,
          ip: request.remote_ip
        )

        # Issue new access token using devise-jwt encoder
        encoder = Warden::JWTAuth::UserEncoder.new
        access_token, _payload = encoder.call(user, :user, nil)

        render json: {
          access_token: access_token,
          refresh_token: new_refresh_token,
          token_type: 'Bearer',
          expires_in: 15.minutes.to_i
        }, status: :ok
      end
    end
  end
end

