class Role < ApplicationRecord
  belongs_to :account, optional: true
  has_and_belongs_to_many :users, join_table: :users_roles
  has_and_belongs_to_many :permissions, join_table: :roles_permissions

  acts_as_tenant(:account)

  scope :global, -> { where(account_id: nil) }
  scope :tenant_owned, -> { where.not(account_id: nil) }

  validates :name, presence: true, uniqueness: { scope: :account_id }
  validate :superadmin_role_is_global
  validate :prevent_superadmin_mutation, on: :update

  before_destroy :prevent_superadmin_destroy

  def superadmin?
    name == "superadmin" && account_id.nil?
  end

  def tenant_editable?
    !superadmin?
  end

  private

  def superadmin_role_is_global
    return unless name == "superadmin"
    return if account_id.nil?

    errors.add(:account, "must be blank for superadmin")
  end

  def prevent_superadmin_mutation
    return unless self.class.unscoped.where(id: id, name: "superadmin", account_id: nil).exists?
    return unless will_save_change_to_name? || will_save_change_to_account_id?

    errors.add(:base, "superadmin role is reserved")
  end

  def prevent_superadmin_destroy
    return unless self.class.unscoped.where(id: id, name: "superadmin", account_id: nil).exists?

    errors.add(:base, "superadmin role cannot be destroyed")
    throw(:abort)
  end
end
