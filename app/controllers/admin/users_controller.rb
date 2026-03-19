module Admin
  class UsersController < Admin::ApplicationController
    private

    def new_resource(params = {})
      super.tap do |user|
        user.account ||= current_account unless superadmin?
      end
    end

    def resource_params
      permitted = params.require(resource_class.model_name.param_key).permit(:email, :account_id, role_ids: [])

      permitted[:account_id] = current_account.id unless superadmin?
      permitted[:role_ids] = allowed_roles_for(permitted[:role_ids])
      permitted
    end

    def allowed_roles_for(role_ids)
      ids = Array(role_ids).reject(&:blank?)
      scope = superadmin? ? Role.all : Role.where(account_id: current_account.id)
      scope.where(id: ids).pluck(:id)
    end
  end
end
