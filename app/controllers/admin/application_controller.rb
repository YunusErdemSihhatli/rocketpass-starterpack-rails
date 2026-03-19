module Admin
  class ApplicationController < Administrate::ApplicationController
    before_action :authenticate_user!
    before_action :authenticate_admin

    helper_method :current_account, :superadmin?

    private

    def authenticate_admin
      unless current_user&.admin_panel_access?
        redirect_to root_path, alert: "Admin paneline erişim izniniz yok."
      end
    end

    def superadmin?
      current_user&.superadmin?
    end

    def current_account
      current_user&.account
    end

    def superadmin_only!
      return if superadmin?

      redirect_to root_path, alert: "Bu işlem sadece superadmin için kullanılabilir."
    end

    def scoped_resource
      admin_scope(super)
    end

    def find_resource(param)
      admin_scope(resource_class).find(param)
    end

    def admin_scope(relation)
      return relation if superadmin?

      if relation.klass == Account
        relation.where(id: current_account.id)
      elsif relation.klass.column_names.include?("account_id")
        relation.where(account_id: current_account.id)
      else
        relation
      end
    end
  end
end
