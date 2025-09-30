class Profile < ApplicationRecord
  belongs_to :account
  belongs_to :user

  acts_as_tenant :account

  include PgSearch::Model
  pg_search_scope :search_text,
                  against: %i[first_name last_name bio],
                  using: { tsearch: { prefix: true } }

  validates :first_name, presence: true
  validates :last_name, presence: true

  has_one_attached :avatar
  validates :avatar, attached: false, content_type: ["image/png", "image/jpg", "image/jpeg", "image/webp"], size: { less_than: 5.megabytes }

  def full_name
    [first_name, last_name].join(' ')
  end

  # Ransack allowlist (Rails 7+ güvenlik için)
  def self.ransackable_attributes(_auth_object = nil)
    %w[first_name last_name bio user_id account_id created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user account]
  end
end
