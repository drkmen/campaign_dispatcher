class Recipient < ApplicationRecord
  belongs_to :campaign

  enum :status, { queued: 0, sent: 1, failed: 2 }, default: :queued

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, presence: true

  after_update_commit -> {
    broadcast_replace_to "campaign_#{campaign_id}_recipients",
                         target: "recipient_#{id}",
                         partial: "recipients/recipient",
                         locals: { recipient: self }
  }
end
