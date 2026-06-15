class DispatchCampaignJob < ApplicationJob
  queue_as :default

  def perform(campaign_id)
    campaign = Campaign.find(campaign_id)
    return if campaign.completed?

    campaign.processing!

    campaign.recipients.where(status: :queued).find_each do |recipient|
      process_recipient(recipient)
    end

    campaign.completed!
  end

  private

  def process_recipient(recipient)
    # Simulate API call delay
    sleep(rand(1..3))

    # Simulate random failure (5% chance)
    if rand < 0.05
      recipient.failed!
    else
      recipient.sent!
    end
  rescue StandardError => e
    Rails.logger.error("Failed to process recipient #{recipient.id}: #{e.message}")
    recipient.failed!
  end
end
