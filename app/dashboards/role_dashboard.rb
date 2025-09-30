require "administrate/base_dashboard"

class RoleDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    name: Field::String,
    users: Field::HasMany,
    permissions: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id name permissions users].freeze

  SHOW_PAGE_ATTRIBUTES = %i[id name permissions users created_at updated_at].freeze

  FORM_ATTRIBUTES = %i[name permissions users].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(role)
    role.name
  end
end

