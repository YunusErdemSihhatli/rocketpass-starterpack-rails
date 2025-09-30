require "administrate/base_dashboard"

class AccountDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    name: Field::String,
    users: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id name users].freeze

  SHOW_PAGE_ATTRIBUTES = %i[id name users created_at updated_at].freeze

  FORM_ATTRIBUTES = %i[name].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(account)
    account.name
  end
end

