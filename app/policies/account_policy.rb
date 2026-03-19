class AccountPolicy < ApplicationPolicy
  def index?
    superadmin? || admin?
  end

  def show?
    superadmin? || same_account?
  end

  def create?
    superadmin?
  end

  def update?
    superadmin?
  end

  def destroy?
    superadmin?
  end
end
