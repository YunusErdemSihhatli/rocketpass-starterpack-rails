module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization

      before_action :authenticate_user!
      before_action :set_active_storage_url_options
      before_action :set_tenant

      rescue_from Pundit::NotAuthorizedError do
        render json: { error: 'not_authorized' }, status: :forbidden
      end

      private

      def set_tenant
        ActsAsTenant.current_tenant = current_user&.account
      end

      def set_active_storage_url_options
        ActiveStorage::Current.url_options = { host: request.host, protocol: request.protocol, port: request.optional_port }
      end
    end
  end
end
