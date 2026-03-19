class UserPolicy < ApplicationPolicy
  def index?
    superadmin? || admin?
  end

  def show?
    same_account?
  end

  def create?
    superadmin? || admin?
  end

  def update?
    same_account? && (superadmin? || admin?)
  end

  def destroy?
    same_account? && (superadmin? || admin?)
  end

  class Scope < Scope
    def resolve
      super
    end
  end
end
