module Admin
  class InvitationsController < Admin::ApplicationController
    def new
    end

    def create
      email = params.require(:invitation).permit(:email)[:email]
      user = User.invite!({ email: email, account: current_user.account }, current_user)
      if user.persisted?
        redirect_to admin_user_path(user), notice: "Davet gönderildi: #{email}"
      else
        flash.now[:alert] = user.errors.full_messages.to_sentence
        render :new, status: :unprocessable_entity
      end
    end
  end
end

