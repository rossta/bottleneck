class Project < ActiveRecord::Base
  include Redis::Objects
  include RedisKeys
  include TrelloFetchable
  attr_accessible :name, :uid, :trello_url, :trello_organization_id, :trello_closed,
    :time_zone

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
  set :list_history

  resourcify

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

  def record_interval(now = time_zone_now)
    IntervalRecording.new(project: self, now: now).record
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

  def time_zone_now
    Clock.zone_time(time_zone)
  end

  class IntervalRecording
    include RedisKeys

    delegate :interval, :list_ids, :cards, :time_zone_now,
      to: :project, prefix: true

    attr_accessor :project, :now

    def initialize(attrs = {})
      @project  = attrs[:project]
      @now      = attrs[:now]
    end

    def record
      redis.pipelined do
        project.list_history.merge(list_ids)
        project_interval.store(interval_key(today, :card_count), card_count)
        project_interval.store(interval_key(today, :list_ids), list_ids)
      end
      record_end_of_day_summary if near_end_of_day?

      project.lists.map { |list| list.record_interval(now, end_of_day: near_end_of_day?) }
    end

    def record_end_of_day_summary
      return if project_interval.has_key?(interval_key(today))

      project_interval.store(interval_key(today), now.to_i)
      project_interval.incr(:total, 1)
      project_interval.incr(:cards, card_count)
    end

    def now
      @now ||= project_time_zone_now
    end

    def today
      now.to_date
    end

    def card_count
      @count ||= project_cards.count
    end

    def list_ids
      @list_ids ||= project_list_ids
    end

    def near_end_of_day?
      hrs_til_midnight <= 1
    end

    def hrs_til_midnight
      ((now.end_of_day - now) / 1.hour).to_i
    end
  end
end
