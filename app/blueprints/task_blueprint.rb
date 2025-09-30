class TaskBlueprint < BaseBlueprint
  identifier :id

  fields :user_id, :account_id, :title, :description, :state, :created_at, :updated_at
end

