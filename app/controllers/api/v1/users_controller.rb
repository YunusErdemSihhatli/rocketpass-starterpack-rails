module Api
  module V1
    class UsersController < BaseController
      def me
        render json: {
          id: current_user.id,
          email: current_user.email,
          account_id: current_user.account_id,
          roles: current_user.roles.pluck(:name),
          permissions: current_user.permission_keys
        }
      end
    end
  end
end

