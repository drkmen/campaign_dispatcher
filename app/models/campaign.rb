class Campaign < ApplicationRecord
  has_many :recipients, dependent: :destroy
  accepts_nested_attributes_for :recipients, allow_destroy: true, reject_if: :all_blank

  enum :status, { pending: 0, processing: 1, completed: 2 }, default: :pending

  validates :title, presence: true

  after_commit :broadcast_progress, on: %i[update create]

  def broadcast_progress
    broadcast_replace_to "campaign_#{id}_status",
                         target: "campaign_progress",
                         partial: "campaigns/progress",
                         locals: { campaign: self.reload }
  end
end
