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

  def record_interval(now = Clock.time)
    IntervalRecording.new(list: self, now: now).record
  end

  def interval_counts(dates)
    interval.bulk_values *date_keys(dates, card_count_key)
  end

  def card_count_key
    case role
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

  class IntervalRecording
    include RedisKeys

    delegate :cards, :card_history, :interval, :card_ids,
      to: :list, prefix: true

    attr_accessor :list, :now

    def initialize(attrs = {})
      @list = attrs[:list]
      @now = attrs[:now]
    end

    def record
      record_all_time_summary
      record_daily_summary
      record_end_of_day_summary

      list_cards.map { |card| card.record_interval(now, end_of_day: near_end_of_day?) }
      card_count
    end

    def record_all_time_summary
      # card ids all time
      list_card_history.merge(card_ids) if card_ids.any?
    end

    def record_daily_summary
      card_cumulative = list_card_history.size

      redis.multi do
        # card count for today
        list_interval.store(date_key(today, :card_count), card_count)

        # card ids for today
        list_interval.store(date_key(today, :card_ids), card_ids)

        # cumulative total by today
        list_interval.store(date_key(today, :cumulative_total), card_cumulative)
      end
    end

    def record_end_of_day_summary
      return if !near_end_of_day?
      return if list_interval.has_key?(date_key(today))

      # end of day interval time stamp
      list_interval.store(date_key(today), now.to_i)

      # intervals all time
      list_interval.incr(:total, 1)

      # card count all time
      list_interval.incr(:card_count, card_count)
    end

    def today
      now.to_date
    end

    def card_count
      @card_count ||= list.cards.count
    end

    def card_ids
      @card_ids ||= list_card_ids
    end

    def near_end_of_day?
      hrs_til_midnight <= 1
    end

    def hrs_til_midnight
      ((now.end_of_day - now) / 1.hour).to_i
    end
  end
end
