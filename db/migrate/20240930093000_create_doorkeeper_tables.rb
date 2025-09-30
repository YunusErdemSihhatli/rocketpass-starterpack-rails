class CreateDoorkeeperTables < ActiveRecord::Migration[8.0]
  def change
    create_table :oauth_applications do |t|
      t.string  :name, null: false
      t.string  :uid, null: false
      t.string  :secret, null: false
      t.text    :redirect_uri
      t.string  :scopes, null: false, default: ''
      t.boolean :confidential, null: false, default: true
      t.timestamps null: false
    end
    add_index :oauth_applications, :uid, unique: true

    create_table :oauth_access_grants do |t|
      t.references :resource_owner, null: false
      t.references :application,    null: false
      t.string   :token,            null: false
      t.integer  :expires_in,       null: false
      t.text     :redirect_uri,     null: false
      t.datetime :created_at,       null: false
      t.string   :scopes,           null: false, default: ''
      t.datetime :revoked_at
    end
    add_index :oauth_access_grants, :token, unique: true

    create_table :oauth_access_tokens do |t|
      t.references :resource_owner
      t.references :application
      t.string   :token,             null: false
      t.string   :refresh_token
      t.integer  :expires_in
      t.datetime :revoked_at
      t.datetime :created_at,        null: false
      t.string   :scopes,            null: false, default: ''
      t.string   :previous_refresh_token, null: false, default: '' # for refresh token rotation
    end
    add_index :oauth_access_tokens, :token, unique: true
    add_index :oauth_access_tokens, :refresh_token, unique: true
  end
end

