module Api
  module V1
    module Users
      class SessionsController < Devise::SessionsController
        respond_to :json
        skip_before_action :verify_authenticity_token

        private

        def respond_with(resource, _opts = {})
          access_token = request.env['warden-jwt_auth.token']
          refresh_record, refresh_token = RefreshToken.generate_for!(
            resource,
            user_agent: request.user_agent,
            ip: request.remote_ip
          )
          render json: {
            message: 'signed_in',
            user: { id: resource.id, email: resource.email },
            access_token: access_token,
            refresh_token: refresh_token,
            token_type: 'Bearer',
            expires_in: 15.minutes.to_i
          }, status: :ok
        end

        def respond_to_on_destroy
          # Optionally revoke provided refresh token on logout
          if params[:refresh_token].present?
            if (rt = RefreshToken.active.find_by_raw(params[:refresh_token]))
              rt.revoke!
            end
          end
          head :no_content
        end
      end
    end
  end
end
