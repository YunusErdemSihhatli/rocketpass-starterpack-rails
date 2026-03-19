module Admin
  class PermissionsController < Admin::ApplicationController
    private

    def new_resource(params = {})
      super.tap do |permission|
        permission.account ||= current_account unless superadmin?
      end
    end

    def resource_params
      permitted = params.require(resource_class.model_name.param_key).permit(:key, :name, :description, :account_id, role_ids: [])

      target_account_id = superadmin? ? permitted[:account_id].presence : current_account.id
      permitted[:account_id] = target_account_id
      permitted[:role_ids] = allowed_roles_for(permitted[:role_ids], target_account_id)
      permitted
    end

    def allowed_roles_for(role_ids, account_id)
      ids = Array(role_ids).reject(&:blank?)
      scope = superadmin? ? Role.all : Role.where(account_id: current_account.id)
      scoped_roles = account_id.present? ? scope.where(account_id: account_id) : scope.where(account_id: nil)
      scoped_roles.where(id: ids).pluck(:id)
    end
  end
end
