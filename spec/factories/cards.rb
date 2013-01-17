# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  sequence(:card_uid) { |n| "50f02b7e6a44c1b264004e34" } # from Bottleneck board on trello

  factory :card do
    uid { generate(:card_uid) }
    name "Task for Later"
    position 1
    # trello_short_id "MyString"
    # trello_closed "MyString"
    # trello_url "MyString"
    # trello_board_id "MyString"
    # trello_member_ids "MyString"
    # trello_list_id "MyString"
  end
end
