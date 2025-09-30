module Api
  module V1
    module Users
      class RegistrationsController < Devise::RegistrationsController
        respond_to :json
        skip_before_action :verify_authenticity_token

        private

        def build_resource(hash = nil)
          super
          resource.account ||= Account.create!(name: (sign_up_params[:account_name].presence || resource.email.split('@').first))
        end

        def sign_up_params
          params.require(:user).permit(:email, :password, :password_confirmation, :account_name)
        end

        def respond_with(resource, _opts = {})
          if resource.persisted?
            access_token = request.env['warden-jwt_auth.token']
            _refresh_record, refresh_token = RefreshToken.generate_for!(
              resource,
              user_agent: request.user_agent,
              ip: request.remote_ip
            )
            render json: {
              message: 'signed_up',
              user: { id: resource.id, email: resource.email },
              access_token: access_token,
              refresh_token: refresh_token,
              token_type: 'Bearer',
              expires_in: 15.minutes.to_i
            }, status: :ok
          else
            render json: { errors: resource.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
