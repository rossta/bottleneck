class Project < ActiveRecord::Base
  include TrelloFetchable
  attr_accessible :name, :uid, :trello_url, :trello_organization_id, :trello_closed

  belongs_to :trello_account
  belongs_to :owner, class_name: 'User'
  has_many :lists, order: 'id ASC', dependent: :destroy

  delegate :token, to: :trello_account, prefix: :trello, allow_nil: true

  trello_representative :trello_board, {
    name: :trello_name,
    url: :trello_url,
    organization_id: :trello_organization_id,
    closed: :trello_closed
  }

  def trello_board
    @trello_board ||= authorize { Trello::Board.find(uid) }
  end

  def trello_lists
    @trello_lists ||= authorize { trello_board.lists }
  end

  def imported?
    lists.any?
  end

  def fetch_lists
    self.lists = trello_lists.map { |trello_list| List.fetch(trello_list, trello_account) }
  end

  def fetch_cards
    self.lists.map(&:fetch_cards)
  end

  def fetch
    super
    fetch_lists
    fetch_cards
  end

  def record_interval
    BoardInterval.record(self)
  end

  def recording_timestamp
    Time.zone.now.send(timestamp_adjustment)
  end

  def timestamp_adjustment
    :end_of_day
  end
end
