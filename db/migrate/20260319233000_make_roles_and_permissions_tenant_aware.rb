class MakeRolesAndPermissionsTenantAware < ActiveRecord::Migration[8.0]
  class MigrationAccount < ActiveRecord::Base
    self.table_name = "accounts"
  end

  class MigrationUser < ActiveRecord::Base
    self.table_name = "users"

    has_and_belongs_to_many :roles,
                            class_name: "MakeRolesAndPermissionsTenantAware::MigrationRole",
                            join_table: "users_roles"
  end

  class MigrationPermission < ActiveRecord::Base
    self.table_name = "permissions"

    belongs_to :account, class_name: "MakeRolesAndPermissionsTenantAware::MigrationAccount", optional: true
    has_and_belongs_to_many :roles,
                            class_name: "MakeRolesAndPermissionsTenantAware::MigrationRole",
                            join_table: "roles_permissions"
  end

  class MigrationRole < ActiveRecord::Base
    self.table_name = "roles"

    belongs_to :account, class_name: "MakeRolesAndPermissionsTenantAware::MigrationAccount", optional: true
    has_and_belongs_to_many :users,
                            class_name: "MakeRolesAndPermissionsTenantAware::MigrationUser",
                            join_table: "users_roles"
    has_and_belongs_to_many :permissions,
                            class_name: "MakeRolesAndPermissionsTenantAware::MigrationPermission",
                            join_table: "roles_permissions"
  end

  def up
    add_reference :roles, :account, foreign_key: true
    add_reference :permissions, :account, foreign_key: true

    backfill_roles!
    backfill_permissions!

    remove_index :roles, :name
    add_index :roles, [ :account_id, :name ], unique: true
    add_index :roles, :name, unique: true, where: "account_id IS NULL", name: "index_roles_on_global_name"

    remove_index :permissions, :key
    add_index :permissions, [ :account_id, :key ], unique: true
    add_index :permissions, :key, unique: true, where: "account_id IS NULL", name: "index_permissions_on_global_key"
  end

  def down
    remove_index :roles, name: "index_roles_on_global_name"
    remove_index :roles, column: [ :account_id, :name ]
    add_index :roles, :name, unique: true

    remove_index :permissions, name: "index_permissions_on_global_key"
    remove_index :permissions, column: [ :account_id, :key ]
    add_index :permissions, :key, unique: true

    remove_reference :permissions, :account, foreign_key: true
    remove_reference :roles, :account, foreign_key: true
  end

  private

  def backfill_roles!
    MigrationRole.reset_column_information

    MigrationRole.includes(:users, :permissions).find_each do |role|
      next if role.name == "superadmin"

      account_ids = role.users.distinct.pluck(:account_id).compact.uniq
      next if account_ids.empty?

      primary_account_id = account_ids.shift
      role.update_columns(account_id: primary_account_id)

      account_ids.each do |account_id|
        duplicated_role = MigrationRole.create!(
          name: role.name,
          account_id: account_id,
          created_at: role.created_at,
          updated_at: role.updated_at
        )

        duplicated_role.permissions << role.permissions

        role.users.where(account_id: account_id).find_each do |user|
          user.roles.delete(role)
          user.roles << duplicated_role
        end
      end
    end
  end

  def backfill_permissions!
    MigrationPermission.reset_column_information

    MigrationPermission.includes(:roles).find_each do |permission|
      account_ids = permission.roles.distinct.pluck(:account_id).compact.uniq
      next if account_ids.empty?

      primary_account_id = account_ids.shift
      permission.update_columns(account_id: primary_account_id)

      account_ids.each do |account_id|
        duplicated_permission = MigrationPermission.create!(
          key: permission.key,
          name: permission.name,
          description: permission.description,
          account_id: account_id,
          created_at: permission.created_at,
          updated_at: permission.updated_at
        )

        permission.roles.where(account_id: account_id).find_each do |role|
          role.permissions.delete(permission)
          role.permissions << duplicated_permission
        end
      end
    end
  end
end
