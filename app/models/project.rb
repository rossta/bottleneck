class Project < ActiveRecord::Base
  include Redis::Objects
  include RedisKeys
  include TrelloFetchable

  attr_accessible :name, :uid, :trello_url, :trello_organization_id, :trello_closed,
    :time_zone

  belongs_to :trello_account
  belongs_to :owner, class_name: 'User'
  has_many :lists, order: 'id ASC', dependent: :destroy
  has_many :cards # includes all
  has_many :current_cards, through: :lists, source: :cards

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

  resourcify

  def trello_board
    @trello_board ||= trello_client.find(:boards, uid)
  end

  def trello_lists
    @trello_lists ||= trello_board.lists
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

  def record_interval(now = zone_time_now)
    IntervalRecording::OfProject.new(of: self, at: now).record
  end

  def timestamp_adjustment
    :end_of_day
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

  def wip_count(date)
    interval[date_key(date, :wip_count)].to_i
  end

  def done_count(date)
    interval[date_key(date, :done_count)].to_i
  end

  # WIP + Done
  def capacity_count(date)
    wip_count(date) + done_count(date)
  end

  # Time to market:
  # days elapsed from when total capacity equaled total now completed
  def cycle_time(date)
    days_ago = 0
    done      = done_count(date)
    capacity  = capacity_count(date)

    # back track one day at a time until capacity
    # was less than or equal to currently done
    while done < capacity
      days_ago += 1
      capacity = capacity_count(date - days_ago.days)
    end
    days_ago
  end

  # Arrival rate = WIP (start of cycle) / Cycle Time
  def arrival_rate(date)
    cycle = cycle_time(date)
    return 0 if cycle.zero?
    (wip_count(date - cycle.days) / cycle).to_f
  end

end
