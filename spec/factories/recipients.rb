FactoryBot.define do
  factory :recipient do
    campaign
    name { "John Doe" }
    email { "john@example.com" }
    status { :queued }
  end
end
