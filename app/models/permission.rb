class Permission < ApplicationRecord
  has_and_belongs_to_many :roles, join_table: :roles_permissions

  validates :key, presence: true, uniqueness: true
  validates :name, presence: true
end

