FactoryGirl.define do
  factory :project do
    name 'Bottleneck'
    uid '50ce927d006f9d1b63010458'  # for Bottleneck board on trello
    trello_account
  end

  factory :project_with_trello_account, parent: :project do
    trello_account
  end
end
