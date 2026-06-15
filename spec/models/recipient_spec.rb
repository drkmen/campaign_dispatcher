require 'rails_helper'

RSpec.describe Recipient, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:campaign) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to allow_value('test@example.com').for(:email) }
    it { is_expected.not_to allow_value('invalid-email').for(:email) }
    it { is_expected.to validate_presence_of(:status) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(queued: 0, sent: 1, failed: 2) }
  end
end
