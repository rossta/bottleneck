class List < ActiveRecord::Base
  include Redis::Objects
  include RedisKeys
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

  hash_key :interval, marshal: true

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

  def record_interval(now = Clock.time, opts = {})
    today = now.to_date
    card_count = cards.count
    end_of_day = opts[:end_of_day] || false
    if end_of_day && !interval_previously_recorded?(today)
      interval.store(interval_key(today), now.to_i)
      interval.incr(:total, 1)
      interval.incr(:card_count, card_count)
    end
    redis.multi do
      interval.store(interval_key(today, :card_count), card_count)
      interval.store(interval_key(today, :card_ids), card_ids)
    end
    cards.map { |card| card.record_interval(now, end_of_day: end_of_day) }
    card_count
  end

  def interval_json(beg_of_period, end_of_period)
    {
      :name => name,
      :data => ListInterval.new(self, beg_of_period, end_of_period).data,
      :position => -id
    }
  end

  def interval_previously_recorded?(date)
    interval.has_key?(interval_key(date))
  end
end
