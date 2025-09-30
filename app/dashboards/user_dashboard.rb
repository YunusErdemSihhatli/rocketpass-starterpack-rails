require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id: Field::Number,
    email: Field::String,
    account: Field::BelongsTo,
    roles: Field::HasMany,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id email account roles].freeze

  SHOW_PAGE_ATTRIBUTES = %i[id email account roles created_at updated_at].freeze

  FORM_ATTRIBUTES = %i[email account roles].freeze

  COLLECTION_FILTERS = {}.freeze

  def display_resource(user)
    user.email
  end
end

