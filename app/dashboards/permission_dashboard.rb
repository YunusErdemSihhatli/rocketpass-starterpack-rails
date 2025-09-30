require "administrate/base_dashboard"

class PermissionDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    key: Field::String,
    name: Field::String,
    description: Field::Text,
    roles: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id key name roles].freeze

  SHOW_PAGE_ATTRIBUTES = %i[id key name description roles created_at updated_at].freeze

  FORM_ATTRIBUTES = %i[key name description roles].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(permission)
    permission.key
  end
end

