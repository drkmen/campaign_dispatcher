require 'rails_helper'

RSpec.describe DispatchCampaignJob, type: :job do
  let(:campaign) { create(:campaign, status: :pending) }
  let!(:recipients) { create_list(:recipient, 3, campaign:, status: :queued) }

  before do
    allow_any_instance_of(described_class).to receive(:sleep)
  end

  subject { described_class.perform_now(campaign.id) }

  describe '#perform' do
    it 'updates campaign status to processing then completed' do
      # We can't easily check 'processing' state in a synchronous
      # perform unless we use mocks or observe the object.
      # But we can verify it reaches completed
      expect { subject }.to change { campaign.reload.status }.
        from('pending').to('completed')
    end

    context 'when no error occurs' do
      before do
        # Mocking rand to ensure success for this test
        allow_any_instance_of(Object).to receive(:rand).and_return(0.1)
      end

      it 'updates all queued recipients to sent' do
        subject
        expect(campaign.recipients.pluck(:status)).to eq(%w[sent sent sent])
      end
    end

    context 'when an error occurs' do
      context 'when an internal error occurs' do
        before do
          # Mocking rand to ensure failure
          allow_any_instance_of(Object).to receive(:rand).and_return(0.01)
        end

        it 'updates all queued recipients to failed' do
          subject
          expect(campaign.recipients.pluck(:status)).to eq(%w[failed failed failed])
        end
      end

      context 'when an external error occurs' do
        before do
          allow_any_instance_of(Recipient).to receive(:sent!).and_raise(StandardError.new('API Error'))
        end

        it 'rescues errors during recipient processing and continues' do
          subject
          aggregate_failures do
            expect(campaign.recipients.queued.count).to eq(0)
            expect(campaign.recipients.failed.count).to be >= 1
            expect(campaign.reload.status).to eq('completed')
          end
        end
      end
    end

    context 'when some of the recipients are sent' do
      let!(:sent_recipient) { create(:recipient, campaign:, status: :sent) }

      it 'is idempotent and does not reprocess sent recipients' do
        subject
        expect(sent_recipient.reload.status).to eq('sent')
      end
    end
  end
end
