class TaskPolicy < ApplicationPolicy
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
    same_account? && (superadmin? || admin? || user == record.user)
  end

  def event?
    update?
  end

  class Scope < Scope
    def resolve
      super
    end
  end
end
