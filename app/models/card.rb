class Card < ActiveRecord::Base
  include Redis::Objects
  include RedisKeys
  include TrelloFetchable

  attr_accessible :uid, :due, :position, :trello_board_id, :trello_closed,
    :trello_list_id, :trello_name, :trello_short_id, :trello_url

  attr_accessor :trello_card

  trello_api_adapter :trello_card, {
    name:     :name,
    board_id: :trello_board_id,
    closed:   :trello_closed,
    short_id: :trello_short_id,
    name:     :trello_name,
    close:    :trello_closed,
    url:      :trello_url,
    board_id: :trello_board_id,
    list_id:  :trello_list_id,
    pos:      :position,
    due:      :due_at
  }

  belongs_to :trello_account
  belongs_to :list
  belongs_to :project

  hash_key :interval, marshal: true
  set :list_history

  delegate :labels, to: :trello_card, allow_nil: true

  attr_accessor :trello_token

  def self.fetch(trello_card, trello_account)
    card = find_or_initialize_by_uid(trello_card.id)
    card.trello_card = trello_card
    card.trello_account = trello_account
    card.fetch
  end

  def name
    trello_name
  end

  def trello_card
    @trello_card ||= authorize { Trello::Card.find(uid) }
  end

  def trello_token
    @trello_token ||= project.try(:trello_token)
  end

  def record_interval(now = Clock.time, opts = {})
    IntervalRecording::OfCard.new(of: self, at: now).record
  end

  ListCount = Struct.new(:list, :count) do
    def x; list.name; end
    def y; (count || 0).to_i; end
  end

  def list_counts
    list_ids  = list_history.members.map(&:to_i)
    lists     = project.lists.select("lists.id, lists.name")
    counts    = list_ids.map { |list_id| interval[redis_key(:list_total, list_id)] }
    list_counts = lists.zip(counts).map { |tuple| ListCount.new(tuple[0], tuple[1]) }
    list_counts.map { |lc| { x: lc.x, y: lc.y } }
  end

  def after_save
    return unless list_id && list_id.changed?
    self.project = list.project
    save
  end

end
