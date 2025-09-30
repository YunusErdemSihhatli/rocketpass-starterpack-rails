class AddInvitableToUsers < ActiveRecord::Migration[8.0]
  def change
    change_table :users do |t|
      t.string   :invitation_token
      t.datetime :invitation_created_at
      t.datetime :invitation_sent_at
      t.datetime :invitation_accepted_at
      t.integer  :invitation_limit
      t.references :invited_by, polymorphic: true
      t.integer :invitations_count, default: 0
    end

    add_index :users, :invitation_token, unique: true
    add_index :users, :invited_by_id
  end
end

