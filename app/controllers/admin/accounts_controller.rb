module Admin
  class AccountsController < Admin::ApplicationController
    before_action :superadmin_only!
  end
end
