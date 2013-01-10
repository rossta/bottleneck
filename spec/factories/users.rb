# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:name) { |n| "jerry #{n}" }
  sequence(:email) { |n| "example#{n}@example.com" }

  factory :user do
    name
    email
    password 'password'
    password_confirmation 'password'
    # required if the Devise Confirmable module is used
    # confirmed_at Time.now
  end
end
