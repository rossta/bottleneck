# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :card do
    trello_name "Task for Later"
    position 1
    # trello_short_id "MyString"
    # trello_closed "MyString"
    # trello_url "MyString"
    # trello_board_id "MyString"
    # trello_member_ids "MyString"
    # trello_list_id "MyString"
  end
end
