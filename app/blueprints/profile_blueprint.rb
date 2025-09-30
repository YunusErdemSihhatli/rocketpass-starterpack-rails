class ProfileBlueprint < BaseBlueprint
  identifier :id

  fields :user_id, :account_id, :first_name, :last_name, :bio

  field :full_name

  field :avatar_url do |profile|
    if profile.avatar.attached?
      Rails.application.routes.url_helpers.rails_blob_url(profile.avatar)
    end
  end

  field :avatar_thumb_url do |profile|
    if profile.avatar.attached?
      variant = profile.avatar.variant(resize_to_limit: [200, 200]).processed
      Rails.application.routes.url_helpers.url_for(variant)
    end
  end
end
