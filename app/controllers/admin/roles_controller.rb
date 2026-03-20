module Admin
  class RolesController < Admin::ApplicationController
    before_action :prevent_reserved_superadmin_access!, only: %i[edit update destroy]

    private

    def new_resource(params = {})
      super.tap do |role|
        role.account ||= current_account unless superadmin?
      end
    end

    def resource_params
      role_params = params.require(resource_class.model_name.param_key)
      permitted = role_params.permit(:name)

      target_account_id = normalized_account_id(role_params[:account_id])
      permitted[:account_id] = target_account_id
      permitted[:permission_ids] = allowed_permissions_for(role_params[:permission_ids], target_account_id)
      permitted[:user_ids] = allowed_users_for(role_params[:user_ids], target_account_id)
      permitted
    end

    def normalized_account_id(account_id)
      return current_account.id unless superadmin?

      account_id.presence
    end

    def allowed_permissions_for(permission_ids, account_id)
      ids = Array(permission_ids).reject(&:blank?)
      scope = superadmin? ? Permission.all : Permission.where(account_id: current_account.id)
      scoped_permissions = account_id.present? ? scope.where(account_id: account_id) : scope.where(account_id: nil)
      scoped_permissions.where(id: ids).pluck(:id)
    end

    def allowed_users_for(user_ids, account_id)
      ids = Array(user_ids).reject(&:blank?)
      scope = superadmin? ? User.all : User.where(account_id: current_account.id)
      scoped_users = account_id.present? ? scope.where(account_id: account_id) : scope
      scoped_users.where(id: ids).pluck(:id)
    end

    def prevent_reserved_superadmin_access!
      return unless requested_resource.superadmin?

      redirect_to admin_roles_path, alert: "Reserved superadmin role cannot be modified from the admin panel."
    end
  end
end
