class List < ActiveRecord::Base
  include Redis::Objects
  include RedisKeys

  include Extensions::Age
  include Extensions::TrelloFetchable

  ROLES = [
    BACKLOG = "Backlog",
    WIP = "WIP",
    DONE = "Done",
    IGNORE = "Ignore"
  ]

  attr_accessible :name, :uid, :role, :position
  attr_accessor :trello_list

  delegate :token, :client, to: :trello_account, prefix: :trello, allow_nil: true

  trello_api_adapter :trello_list, {
    name:     :name,
    board_id: :trello_board_id,
    closed:   :trello_closed
  }

  belongs_to :trello_account
  belongs_to :project
  has_many :cards

  hash_key :interval, marshal: true
  set :card_history

  default_scope order("#{table_name}.position ASC")

  scope :reverse_order, reorder("#{table_name}.position DESC")
  scope :backlog, where(role: BACKLOG)
  scope :wip, where(role: WIP)
  scope :done, where(role: DONE)

  def self.arel_role(role, t = arel_table)
    t[:role].eq(role)
  end

  def self.arel_roles(role, *or_roles)
    table = self.arel_table
    match = arel_role(role)
    or_roles.each do |or_role|
      match = match.or(arel_role(or_role))
    end
    match
  end
  scope :flow, where(arel_roles(BACKLOG, WIP, DONE))

  def self.fetch(trello_list, trello_account)
    list = find_or_initialize_by_uid(trello_list.id)
    list.trello_list = trello_list
    list.trello_account = trello_account
    list.fetch
  end

  def trello_list
    @trello_list ||= trello_client.find(:lists, uid)
  end

  def trello_cards
    @trello_cards ||= trello_list.cards
  end

  def fetch_cards
    self.cards = trello_cards.map { |trello_card| Card.fetch(trello_card, trello_account) }
  end

  def card_names
    cards.map(&:name)
  end

  def card_count
    cards.count
  end

  def record_interval(now = Clock.time)
    Interval::ListRecording.new(of: self, at: now).record
  end

  def interval_counts(dates)
    interval.bulk_values *date_keys(dates, card_count_key)
  end

  def cumulative_total(date = Clock.date)
    interval[date_key(date, :cumulative_total)].to_i
  end

  def card_count_key
    case role
    when DONE
      :cumulative_total # all-time
    else
      :card_count       # daily
    end
  end

  CardCount = Struct.new(:card, :count) do
    def x; card.name; end
    def y; (count || 0).to_i; end
    def attributes; { x: x, y: y }; end
  end

  PositionCount = Struct.new(:position, :card, :count) do
    def x; position.to_i; end
    def y; (count || 0).to_i; end
    def to_json; { name: card.name, data: [{ x: x, y: y }] }; end
  end

  def card_days
    counts = cards.map { |card| card.list_day_count(id) }
    cards.zip(counts).map { |tuple| new_card_count(*tuple) }.map(&:attributes)
  end

  def card_days_alt
    position = 0
    counts = cards.map { |card| card.list_day_count(id) }
    cards.zip(counts).map { |tuple|
      position += 1;
      PositionCount.new(position, *tuple)
    }.map(&:to_json)
  end

  def new_card_count(card, count)
    CardCount.new(card, count)
  end

  def clear_history
    interval.clear
    card_history.clear
  end

end
