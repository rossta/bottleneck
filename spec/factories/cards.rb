# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :card do
    trello_short_id "MyString"
    trello_name "MyString"
    due "2012-12-17 23:12:53"
    trello_closed "MyString"
    trello_url "MyString"
    trello_board_id "MyString"
    trello_member_ids "MyString"
    trello_list_id "MyString"
    position 1
  end
end
