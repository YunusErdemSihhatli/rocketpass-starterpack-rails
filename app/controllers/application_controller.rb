class ApplicationController < ActionController::Base
  include Pundit::Authorization

  protect_from_forgery with: :exception

  before_action :authenticate_user!
  before_action :set_locale
  before_action :set_tenant

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  private

  def set_tenant
    # Scope data access by the signed-in user's account
    if current_user&.account
      ActsAsTenant.current_tenant = current_user.account
    else
      ActsAsTenant.current_tenant = nil
    end
  end

  def user_not_authorized
    respond_to do |format|
      format.html do
        redirect_to(root_path, alert: I18n.t('controllers.admin.not_authorized'))
      end
      format.json do
        render json: { error: "not_authorized" }, status: :forbidden
      end
    end
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
