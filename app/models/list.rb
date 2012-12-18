class List < ActiveRecord::Base
  include TrelloFetchable

  attr_accessible :name, :uid, :role
  attr_accessor :trello_list

  delegate :token, to: :trello_account, prefix: :trello, allow_nil: true

  trello_representative :trello_list, {
    name: :name,
    board_id: :trello_board_id,
    closed: :trello_closed
  }

  belongs_to :trello_account
  belongs_to :project
  has_many :cards

  ROLES = %w(Backlog WIP Done Ignore)

  def self.fetch(trello_list, trello_account)
    list = find_or_initialize_by_uid(trello_list.id)
    list.trello_list = trello_list
    list.trello_account = trello_account
    list.fetch
  end

  def trello_list
    @trello_list ||= authorize { Trello::List.find(uid) }
  end

  def trello_cards
    @trello_cards ||= authorize { trello_list.cards }
  end

  def fetch_cards
    self.cards = trello_cards.map { |trello_card| Card.fetch(trello_card, trello_account) }
  end

  def card_names
    cards.map(&:name)
  end

end
