class PermissionPolicy < ApplicationPolicy
  def index?
    superadmin? || admin?
  end

  def show?
    superadmin? || same_account?
  end

  def create?
    superadmin? || admin?
  end

  def update?
    superadmin? || (admin? && same_account?)
  end

  def destroy?
    superadmin? || (admin? && same_account?)
  end
end
