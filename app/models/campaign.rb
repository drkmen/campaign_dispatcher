class Campaign < ApplicationRecord
  has_many :recipients, dependent: :destroy

  enum :status, { pending: 0, processing: 1, completed: 2 }, default: :pending

  validates :title, presence: true
end
