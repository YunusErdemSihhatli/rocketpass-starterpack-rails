class User < ApplicationRecord
  include Devise::JWT::RevocationStrategies::JTIMatcher
  # Devise modules: add others as needed (e.g., :confirmable, :lockable)
  devise :invitable, :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable, :trackable,
         :jwt_authenticatable, jwt_revocation_strategy: self

  # Roles
  has_and_belongs_to_many :roles, join_table: :users_roles
  has_many :refresh_tokens, dependent: :destroy

  # Tenancy
  belongs_to :account, optional: false

  # ActsAsTenant scopes for multi-tenancy readiness
  acts_as_tenant(:account)

  # Optional user preferred locale (e.g., 'en' or 'tr')
  validates :locale, inclusion: { in: I18n.available_locales.map(&:to_s) }, allow_nil: true

  def preferred_locale
    locale.presence
  end

  def superadmin?
    roles.where(name: "superadmin", account_id: nil).exists?
  end

  def admin?(account: self.account)
    roles.where(name: "admin", account_id: extract_account_id(account)).exists?
  end

  def admin_panel_access?(account: self.account)
    superadmin? || admin?(account: account)
  end

  def has_role?(role_name, account: self.account)
    role_name = role_name.to_s
    return superadmin? if role_name == "superadmin"

    roles.where(name: role_name, account_id: extract_account_id(account)).exists?
  end

  def permission_keys(account: self.account)
    return [ "*" ] if superadmin?

    roles
      .where(account_id: extract_account_id(account))
      .includes(:permissions)
      .flat_map { |role| role.permissions.select { |permission| permission.account_id == role.account_id }.map(&:key) }
      .uniq
  end

  def can?(permission_key, account: self.account)
    return true if superadmin?

    permission_keys(account: account).include?(permission_key.to_s)
  end

  private

  def extract_account_id(account)
    case account
    when Account
      account.id
    else
      account || account_id
    end
  end
end
