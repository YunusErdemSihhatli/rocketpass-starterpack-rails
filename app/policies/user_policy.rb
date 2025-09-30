class UserPolicy < ApplicationPolicy
  def index?
    admin?
  end

  def show?
    admin? || same_account?
  end

  def create?
    admin?
  end

  def update?
    admin?
  end

  def destroy?
    admin?
  end

  class Scope < Scope
    def resolve
      return scope.none unless user
      return scope.all if admin?
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

