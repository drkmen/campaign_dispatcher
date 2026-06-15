require 'rails_helper'

RSpec.describe "Campaigns", type: :request do
  describe "POST /campaigns" do
    let(:valid_params) do
      {
        campaign: {
          title: "Test Campaign",
          recipients_attributes: [
            { name: "John Doe", email: "john@example.com" },
            { name: "Jane Smith", email: "jane@example.com" }
          ]
        }
      }
    end

    subject { post campaigns_path, params: valid_params }

    it "creates a new Campaign" do
      expect { subject }.to change(Campaign, :count).by(1)
    end

    it "creates recipients from nested attributes" do
      expect { subject }.to change(Recipient, :count).by(2)
    end

    it "enqueues DispatchCampaignJob" do
      ActiveJob::Base.queue_adapter = :test
      expect { subject }.to enqueue_job(DispatchCampaignJob)
    end

    it "redirects to the created campaign" do
      subject
      expect(response).to redirect_to(Campaign.last)
    end
  end
end
