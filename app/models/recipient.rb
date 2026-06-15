class Recipient < ApplicationRecord
  belongs_to :campaign

  enum :status, { queued: 0, sent: 1, failed: 2 }, default: :queued

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :status, presence: true

  after_commit :broadcast_updates, on: %i[update create]

  def broadcast_updates
    # Update individual recipient row
    broadcast_replace_to "campaign_#{campaign_id}_recipients",
                         target: "recipient_#{id}",
                         partial: "recipients/recipient",
                         locals: { recipient: self }

    # Update overall campaign progress
    campaign.broadcast_progress if campaign
  end

  private
end
