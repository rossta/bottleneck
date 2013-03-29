class Project < ActiveRecord::Base
  include Redis::Objects
  include RedisKeys
  include RedisIntervals

  include Extensions::Age
  include Extensions::TrelloFetchable

  attr_accessible :name, :uid, :trello_url, :trello_organization_id, :trello_closed,
    :time_zone

  belongs_to :trello_account
  belongs_to :owner, class_name: 'User'
  has_many :lists, order: 'id ASC', dependent: :destroy
  has_many :cards # includes all
  has_many :current_cards, through: :lists, source: :cards

  scope :trello_based, where('trello_account_id IS NOT NULL')

  delegate :token, :client, to: :trello_account, prefix: :trello, allow_nil: true

  trello_api_adapter :trello_board, {
    name:             :trello_name,
    url:              :trello_url,
    organization_id:  :trello_organization_id,
    closed:           :trello_closed
  }

  hash_key :interval, marshal: true
  set :list_history
  set :card_history
  value :preview_token_value

  attr_writer :imported

  resourcify

  def trello_board
    @trello_board ||= trello_client.find(:boards, uid)
  end

  def trello_lists
    @trello_lists ||= trello_board.lists
  end

  def imported?
    !!@imported || lists.any?
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

  def record_interval(now = zone_time_now)
    Interval::ProjectRecording.new(of: self, at: now).record
  end

  def timestamp_adjustment
    :end_of_day
  end

  def flow_lists(options = {})
    if options[:collapsed]
      [lists.backlog, lists.wip, lists.done]
    else
      lists.flow.reverse_order
    end
  end

  def add_moderator(user)
    user.add_role(:moderator, self)
  end

  def has_moderator?(user)
    user.has_role?(:moderator, self)
  end

  def zone_time_now
    zone_time(Time.now)
  end

  def zone_time(time)
    Clock.zone_time(time_zone, time)
  end

  def time_in_zone
    Clock.zone_time(time_zone)
  end

  def clear_history
    interval.clear
    card_history.clear
    list_history.clear
    lists.map(&:clear_history)
    cards.map(&:clear_history)
  end

  def backlog_count(date)
    interval_date_count date, :backlog_count
  end

  def wip_count(date)
    interval_date_count date, :wip_count
  end

  def done_count(date)
    interval_date_count date, :done_count
  end

  # WIP + Done
  def capacity_count(date)
    wip_count(date) + done_count(date)
  end

  # Time to market:
  # days elapsed from when total capacity equaled total now completed
  def lead_time(date)
    interval_date_count date, :lead_time
  end

  # Arrival rate = WIP (start of cycle) / Lead Time
  def arrival_rate(date)
    cycle = lead_time(date)
    return 0 if cycle.zero?
    (wip_count(date - cycle.days) / cycle).to_f
  end

  def average_lead_time(date_range)
    average_over_range :lead_time, date_range
  end

  def average_wip_count(date_range)
    average_over_range :wip_count, date_range
  end

  def average_arrival_rate(date_range)
    average_over_range :arrival_rate, date_range
  end

  def average_over_range(method, date_range)
    date_range = age_range(date_range.last) if date_range.first < create_date
    (date_range.to_a.map { |date| send(method, date) }.inject(&:+) / date_range.to_a.length).round(2)
  end

end
