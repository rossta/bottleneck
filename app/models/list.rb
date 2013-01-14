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
  set :card_history

  ROLES = [
    BACKLOG = "Backlog",
    WIP = "WIP",
    DONE = "Done",
    IGNORE = "Ignore"
  ]

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

    # card ids all time
    card_history.merge(card_ids)
    card_cumulative = card_history.size

    redis.multi do
      # interval.store(interval_key(today, :card_total), interval[:card_count])

      # card count for today
      interval.store(interval_key(today, :card_count), card_count)

      # card ids for today
      interval.store(interval_key(today, :card_ids), card_ids)

      # cumulative total by today
      interval.store(interval_key(today, :cumulative_total), card_cumulative)
    end

    if opts[:end_of_day] && !interval_previously_recorded?(today)
      # end of day interval time stamp
      interval.store(interval_key(today), now.to_i)

      # intervals all time
      interval.incr(:total, 1)

      # card count all time
      interval.incr(:card_count, card_count)
    end

    cards.map { |card| card.record_interval(now, opts) }
    card_count
  end

  def interval_counts
    list.interval.bulk_values *list.interval_keys(dates, card_count_key)
  end

  def card_count_key
    case list.role
    when DONE
      :cumulative_total # all-time
    else
      :card_count       # daily
    end
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
