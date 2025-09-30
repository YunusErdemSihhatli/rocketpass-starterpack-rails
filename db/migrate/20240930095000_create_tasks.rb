class CreateTasks < ActiveRecord::Migration[8.0]
  def change
    create_table :tasks do |t|
      t.references :account, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.string :title, null: false
      t.text :description
      t.string :state, null: false, default: 'draft'
      t.timestamps
    end

    add_index :tasks, [:account_id, :state]
  end
end

