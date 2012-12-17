# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:account_name) { |n| "trello_account_#{n}" }

  factory :trello_account do
    name
    token "token"
  end
end
