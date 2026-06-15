require 'rails_helper'

RSpec.describe "Campaign Dispatch", type: :system do
  include ActiveJob::TestHelper

  let!(:campaign) { create(:campaign, title: 'Reactive Test Campaign') }
  let!(:recipient) { create(:recipient, campaign:, name: 'Test User', email: "test@example.com") }

  before do
    driven_by(:cuprite, options: {
      js_errors: true,
      headless: true,
      process_timeout: 10,
      browser_options: { "no-sandbox": nil }
    })
  end

  it "updates recipient status and progress in real-time", js: true do
    visit campaign_path(campaign)

    expect(page).to have_content("Reactive Test Campaign")
    expect(page).to have_content("Queued")
    expect(page).to have_content("Sent 0 of 1")

    # Manually trigger the broadcast to simulate background job update
    # Since we're in a test, we want to ensure Turbo Streams are working
    recipient.sent!

    expect(page).to have_content("Pending") # Campaign status should still be pending if we only updated recipient
    expect(page).to have_content("Sent 1 of 1")
    expect(page).to have_content("Sent")

    campaign.processing!
    expect(page).to have_content("Processing")

    campaign.completed!
    expect(page).to have_content("Completed")
  end
end
