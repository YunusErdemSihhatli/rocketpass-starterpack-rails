class UserBlueprint < BaseBlueprint
  identifier :id

  fields :email, :account_id

  field :roles do |user|
    user.roles.pluck(:name)
  end

  field :permissions do |user|
    user.permission_keys
  end
end

