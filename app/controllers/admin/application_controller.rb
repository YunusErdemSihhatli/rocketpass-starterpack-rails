module Admin
  class ApplicationController < Administrate::ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin

    private

    def authenticate_admin
      unless current_user&.has_role?(:admin)
        redirect_to root_path, alert: "Admin paneline erişim izniniz yok."
      end
    end
  end
end

