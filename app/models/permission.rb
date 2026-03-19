class Permission < ApplicationRecord
  belongs_to :account, optional: true
  has_and_belongs_to_many :roles, join_table: :roles_permissions

  acts_as_tenant(:account)

  scope :global, -> { where(account_id: nil) }
  scope :tenant_owned, -> { where.not(account_id: nil) }

  validates :key, presence: true, uniqueness: { scope: :account_id }
  validates :name, presence: true
end
