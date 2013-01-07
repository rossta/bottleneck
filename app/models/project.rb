class Project < ActiveRecord::Base
  include Redis::Objects
  include RedisKeys
  include TrelloFetchable
  attr_accessible :name, :uid, :trello_url, :trello_organization_id, :trello_closed

  belongs_to :trello_account
  belongs_to :owner, class_name: 'User'
  has_many :lists, order: 'id ASC', dependent: :destroy
  has_many :cards, through: :lists

  delegate :token, to: :trello_account, prefix: :trello, allow_nil: true

  trello_representative :trello_board, {
    name: :trello_name,
    url: :trello_url,
    organization_id: :trello_organization_id,
    closed: :trello_closed
  }

  hash_key :interval, marshal: true

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

  def record_interval(now = Time.now)
    today = now.to_date
    card_count = cards.count
    unless interval.has_key?(interval_key(today))
      interval.incr('total', 1)
      interval.incr(:cards, card_count)
    end
    redis.pipelined do
      interval.store(interval_key(today), now.to_i)
      interval.store(interval_key(today, :card_count), card_count)
      interval.store(interval_key(today, :list_ids), list_ids)
    end
    lists.map { |list| list.record_interval(now) }
  end

  def interval_json(beginning_of_period, end_of_period)
    lists.map { |list|
      list.interval_json(beginning_of_period, end_of_period)
    }
  end

  def recording_timestamp
    Time.zone.now.send(timestamp_adjustment)
  end

  def timestamp_adjustment
    :end_of_day
  end
end
