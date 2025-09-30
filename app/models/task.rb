class Task < ApplicationRecord
  belongs_to :account
  belongs_to :user

  acts_as_tenant :account

  validates :title, presence: true

  include AASM

  aasm column: :state do
    state :draft, initial: true
    state :queued
    state :in_progress
    state :completed
    state :failed

    event :queue do
      transitions from: :draft, to: :queued, after: :enqueue_processing
    end

    event :start do
      transitions from: :queued, to: :in_progress
    end

    event :complete do
      transitions from: :in_progress, to: :completed
    end

    event :fail do
      transitions from: [:queued, :in_progress], to: :failed
    end
  end

  def enqueue_processing
    TaskProcessWorker.perform_async(id)
  end

  has_many_attached :files
  validates :files, content_type: ["image/png", "image/jpg", "image/jpeg", "image/webp", "application/pdf"], size: { less_than: 20.megabytes }

  def self.ransackable_attributes(_auth_object = nil)
    %w[title description state user_id account_id created_at updated_at]
  end

  def self.ransackable_associations(_auth_object = nil)
    %w[user account]
  end
end
