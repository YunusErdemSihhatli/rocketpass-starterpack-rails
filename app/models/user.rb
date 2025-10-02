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

  def has_role?(role_name)
    roles.where(name: role_name.to_s).exists?
  end

  def permission_keys
    roles.includes(:permissions).flat_map { |r| r.permissions.pluck(:key) }.uniq
  end

  def can?(permission_key)
    permission_keys.include?(permission_key.to_s)
  end
end
