# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:trello_token) { "c5c951febdf84a1e45ef8234cc5eef382d9643fb6c7f3717cc091a7afa23aad9" }

  factory :trello_account do
    name 'bottleneck'
    token { generate(:trello_token) }
  end
end
