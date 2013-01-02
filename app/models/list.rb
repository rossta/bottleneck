class List < ActiveRecord::Base
  include Redis::Objects
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

  hash_key :card_counter

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

  def record_interval
    card_counter.incr("total", 1)
    card_counter.incr("cards", cards.count)
    card_counter.store(interval_key, cards.count)
    cards.map(&:record_interval)
    cards.count
  end

  def interval_key(date = Date.today)
    project.interval_key(date)
  end

  def interval_keys(*dates)
    dates.map { |date| interval_key(date) }
  end

  class ListInterval
    DateCount = Struct.new(:date, :count) do
      def x; date.to_time.to_i; end
      def y; (count || 0).to_i; end
    end

    attr_reader :list, :beg_of_period, :end_of_period
    def initialize(list, beg_of_period, end_of_period)
      @list, @beg_of_period, @end_of_period = list, beg_of_period, end_of_period
    end

    def data
      date_counts.map { |dc| { x: dc.x, y: dc.y } }
    end

    def dates
      @dates ||= Range.new(beg_of_period.to_date, end_of_period.to_date)
    end

    def counts
      @counts ||= list.card_counter.bulk_values *list.interval_keys(*dates.to_a)
    end

    def date_counts
      dates.to_a.zip(counts).map { |tuple| DateCount.new(tuple[0], tuple[1]) }
    end
  end

  def interval_json(beg_of_period, end_of_period, color)
    {
      :name => name,
      :data => ListInterval.new(self, beg_of_period, end_of_period).data,
      :color => color
    }
  end

  def color_palette
    @color_palette ||= ColorPalette.new
  end

end
