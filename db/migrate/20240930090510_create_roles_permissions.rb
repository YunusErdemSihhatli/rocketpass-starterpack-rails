class CreateRolesPermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :roles_permissions, id: false do |t|
      t.references :role, null: false, foreign_key: true
      t.references :permission, null: false, foreign_key: true
    end
    add_index :roles_permissions, [:role_id, :permission_id], unique: true, name: 'index_roles_permissions_on_role_and_permission'
  end
end

