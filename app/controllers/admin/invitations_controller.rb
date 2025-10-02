module Admin
  class InvitationsController < Admin::ApplicationController
    def new
    end

    def create
      email = params.require(:invitation).permit(:email)[:email]
      result = Users::InviteService.call(email: email, inviter: current_user)
      if result.success?
        redirect_to admin_user_path(result.value), notice: I18n.t('flash.invitations.created', email: email)
      else
        flash.now[:alert] = Array(result.error).to_sentence
        render :new, status: :unprocessable_entity
      end
    end
  end
end
