module Api
  module V1
    class BaseController < ActionController::API
      include Pundit::Authorization

      before_action :authenticate_user!
      before_action :set_locale
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

      def set_locale
        requested = request.headers['X-Locale'].presence || params[:locale].presence
        # Preference order: user.locale -> header/param -> default
        chosen = current_user&.preferred_locale || requested
        I18n.locale = if chosen && I18n.available_locales.map(&:to_s).include?(chosen.to_s)
                        chosen
                      else
                        I18n.default_locale
                      end
      end
    end
  end
end
