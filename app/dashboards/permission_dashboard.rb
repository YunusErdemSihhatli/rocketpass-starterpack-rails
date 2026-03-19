require "administrate/base_dashboard"

class PermissionDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    key: Field::String,
    name: Field::String,
    description: Field::Text,
    account: Field::BelongsTo,
    roles: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id key name account].freeze

  SHOW_PAGE_ATTRIBUTES = %i[id key name account description roles created_at updated_at].freeze

  FORM_ATTRIBUTES = %i[key name account description roles].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(permission)
    permission.key
  end
end
