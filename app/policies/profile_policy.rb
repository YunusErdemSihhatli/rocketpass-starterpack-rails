class ProfilePolicy < ApplicationPolicy
  def index?
    user.present?
  end

  def show?
    same_account?
  end

  def create?
    same_account?
  end

  def update?
    same_account?
  end

  def destroy?
    admin? || same_account?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user
      scope.where(account_id: user.account_id)
    end
  end

  private

  def admin?
    user&.has_role?(:admin)
  end

  def same_account?
    user && record.account_id == user.account_id
  end
end

