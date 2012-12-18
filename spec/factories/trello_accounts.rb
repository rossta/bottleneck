# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:account_name) { |n| "trello_account_#{n}" }

  factory :trello_account do
    name { generate(:account_name) }
    token "aeb20eb3201ad981ffc1a65ee6f3d9225de5491e729835e22ecdb3a5551ac5f9"
  end
end
