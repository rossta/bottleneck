class Card < ActiveRecord::Base
  include Redis::Objects
  include RedisKeys
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

  hash_key :interval, marshal: true

  def self.fetch(trello_card, trello_account)
    card = find_or_initialize_by_uid(trello_card.id)
    card.trello_card = trello_card
    card.trello_account = trello_account
    card.fetch
  end

  def name
    trello_name
  end

  def record_interval(now = Clock.time, opts = {})
    today = now.to_date

    if opts[:end_of_day] && !interval_previously_recorded?(today)
      interval.incr(redis_key(:list_total, list_id), 1)
    end

    redis.pipelined do
      interval.store(interval_key(today), now.to_i)
      interval.store(interval_key(today, :list_id), list_id)
    end
  end

  def interval_previously_recorded?(date)
    interval.has_key?(interval_key(date))
  end

end
