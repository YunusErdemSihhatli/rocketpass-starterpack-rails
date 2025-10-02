module Users
  class InviteService < ApplicationService
    def initialize(email:, inviter:, account: nil)
      @email = email
      @inviter = inviter
      @account = account || inviter&.account
    end

    def call
      return failure(I18n.t('services.users.invite.errors.email_required'), code: :bad_request) if @email.blank?
      return failure(I18n.t('services.users.invite.errors.inviter_required'), code: :forbidden) if @inviter.blank?
      return failure(I18n.t('services.users.invite.errors.account_required'), code: :unprocessable_entity) if @account.blank?

      user = User.invite!({ email: @email, account: @account }, @inviter)

      if user.persisted?
        success(user)
      else
        failure(user.errors.full_messages)
      end
    end
  end
end
