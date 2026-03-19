class ApplicationPolicy
  attr_reader :user, :record

  def initialize(user, record)
    @user = user
    @record = record
  end

  def index?
    user.present?
  end

  def show?
    superadmin? || same_account?
  end

  def create?
    superadmin? || admin?
  end

  def new?
    create?
  end

  def update?
    superadmin? || admin?
  end

  def edit?
    update?
  end

  def destroy?
    superadmin? || admin?
  end

  def scope
    Pundit.policy_scope!(user, record.class)
  end

  private

  def superadmin?
    user&.superadmin?
  end

  def admin?
    user&.admin?
  end

  def same_account?(target = record)
    return false unless user
    return true if superadmin?

    target_account_id = account_id_for(target)
    target_account_id.present? && target_account_id == user.account_id
  end

  def account_id_for(target)
    return target.id if target.is_a?(Account)
    return target.account_id if target.respond_to?(:account_id)

    nil
  end

  class Scope
    attr_reader :user, :scope

    def initialize(user, scope)
      @user = user
      @scope = scope
    end

    def resolve
      return scope.none unless user
      return scope.all if user.superadmin?

      if scope <= Account
        scope.where(id: user.account_id)
      elsif scope.column_names.include?("account_id")
        scope.where(account_id: user.account_id)
      else
        scope.all
      end
    end
  end
end
