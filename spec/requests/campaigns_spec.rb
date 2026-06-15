require 'rails_helper'

RSpec.describe 'Campaigns', type: :request do
  describe 'POST /campaigns' do
    let(:title) { 'Test Campaign' }
    let(:recipients_attributes) do
      [
        { name: 'John Doe', email: 'john@example.com' },
        { name: 'Jane Smith', email: 'jane@example.com' }
      ]
    end

    let(:params) do
      {
        campaign: {
          title:,
          recipients_attributes:
        }
      }
    end

    subject { post(campaigns_path, params:) }

    context 'when params are valid' do
      it 'creates a new Campaign' do
        expect { subject }.to change(Campaign, :count).by(1)
      end

      it 'creates recipients from nested attributes' do
        expect { subject }.to change(Recipient, :count).by(2)
      end

      it 'enqueues DispatchCampaignJob' do
        ActiveJob::Base.queue_adapter = :test
        expect { subject }.to enqueue_job(DispatchCampaignJob)
      end

      it 'redirects to the created campaign' do
        subject
        expect(response).to redirect_to(Campaign.last)
      end
    end

    context 'when params are invalid' do
      let(:title) { '' }

      it 'does not create a Campaign' do
        expect { subject }.not_to change(Campaign, :count)
      end
    end
  end
end
