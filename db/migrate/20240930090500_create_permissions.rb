class CreatePermissions < ActiveRecord::Migration[8.0]
  def change
    create_table :permissions do |t|
      t.string :key, null: false
      t.string :name, null: false
      t.text :description
      t.timestamps
    end
    add_index :permissions, :key, unique: true
  end
end

