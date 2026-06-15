require 'rails_helper'

RSpec.describe Campaign, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:recipients).dependent(:destroy) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:title) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:status).with_values(pending: 0, processing: 1, completed: 2) }
  end
end
