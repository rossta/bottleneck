class List < ActiveRecord::Base
  include TrelloFetchable

  attr_accessible :name, :uid
  attr_accessor :trello_list, :role

  trello_representative :trello_list, {
    name: :name,
    board_id: :trello_board_id,
    closed: :trello_closed
  }

  belongs_to :project

  ROLES = %w(Backlog WIP Done Ignore)

  def self.from_trello_list(trello_list)
    list = find_or_initialize_by_uid(trello_list.id)
    list.trello_list = trello_list
    list.fetch
  end

  def trello_list
    @trello_list ||= authorize { Trello::List.find(uid) }
  end

end
