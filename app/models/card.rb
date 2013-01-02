class Card < ActiveRecord::Base
  include Redis::Objects
  include TrelloFetchable

  attr_accessible :due, :position, :trello_board_id, :trello_closed,
    :trello_list_id, :trello_name, :trello_short_id, :trello_url

  attr_accessor :trello_card

  trello_representative :trello_card, {
    name: :name,
    board_id: :trello_board_id,
    closed: :trello_closed,
    short_id: :trello_short_id,
    name: :trello_name,
    close: :trello_closed,
    url: :trello_url,
    board_id: :trello_board_id,
    list_id: :trello_list_id,
    pos: :position,
    due: :due_at
  }

  belongs_to :trello_account
  belongs_to :list

  delegate :project, to: :list

  hash_key :list_interval

  def self.fetch(trello_card, trello_account)
    card = find_or_initialize_by_uid(trello_card.id)
    card.trello_card = trello_card
    card.trello_account = trello_account
    card.fetch
  end

  def name
    trello_name
  end

  def record_interval
    list_interval.store(interval_key, list_id)
  end

  def interval_key
    project.interval_key
  end

end
