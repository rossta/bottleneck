FactoryGirl.define do
  sequence(:project_uid) { '50ce927d006f9d1b63010458' } # for Bottleneck board on trello

  factory :project do
    name 'Bottleneck'
    uid { generate(:project_uid) }
    time_zone 'Pacific Time (US & Canada)'
    trello_account
  end

  factory :project_with_trello_account, parent: :project do
    trello_account
  end
end
