class Card < ActiveRecord::Base
  include Redis::Objects
  include RedisKeys
  include TrelloFetchable

  attr_accessible :uid, :due, :position, :trello_board_id, :trello_closed,
    :trello_list_id, :name, :trello_short_id, :trello_url

  attr_accessor :trello_card

  trello_api_adapter :trello_card, {
    name:     :name,
    board_id: :trello_board_id,
    closed:   :trello_closed,
    short_id: :trello_short_id,
    url:      :trello_url,
    list_id:  :trello_list_id,
    pos:      :position,
    due:      :due_at,
    labels:   :labels
  }

  belongs_to :trello_account
  belongs_to :list
  belongs_to :project

  hash_key :interval, marshal: true
  set :list_history
  list :label_list, marshal: true

  delegate :labels, to: :trello_card, allow_nil: true, prefix: true
  delegate :token, :client, to: :trello_account, allow_nil: true, prefix: :trello

  attr_accessor :trello_token, :trello_card

  before_save :denormalize_project
  after_create :update_label_list

  def self.fetch(trello_card, trello_account)
    card = find_or_initialize_by_uid(trello_card.id)
    card.trello_card = trello_card
    card.trello_account = trello_account
    card.fetch
  end

  def display_name
    return "[Unlabeled]" if name.blank?
    [name, label_display_names].reject(&:blank?).join(' ')
  end

  def label_display_names
    return "" if labels.empty?
    "(#{label_names.join(', ')})"
  end

  def labels
    @labels || (persisted? ? label_list.values : [])
  end

  def labels=(given_labels)
    @labels = given_labels.map { |label| label.respond_to?(:attributes) ? label.attributes : label }
    update_label_list if persisted?
  end

  def label_names
    labels.map { |label| label[:name] }
  end

  def trello_card
    @trello_card ||= begin
      if trello_client && uid
        trello_client.find(:cards, uid)
      else
        nil
      end
    end
  end

  def record_interval(now = Clock.time, opts = {})
    IntervalRecording::OfCard.new(of: self, at: now).record
  end

  ListCount = Struct.new(:list, :count) do
    def x; list.name; end
    def y; (count || 0).to_i; end
  end

  def list_days
    list_ids  = list_history.members.map(&:to_i)
    lists     = project.lists.select("lists.id, lists.name")
    counts    = list_ids.map { |list_id| interval[redis_key(:list_total, list_id)] }
    list_counts = lists.zip(counts).map { |tuple| ListCount.new(tuple[0], tuple[1]) }
    list_counts.map { |lc| { x: lc.x, y: lc.y } }
  end

  def list_day_count(given_list_id)
    interval[redis_key(:list_total, given_list_id)] || 0
  end

  def clear_history
    interval.clear
    list_history.clear
    label_list.clear
  end

  private

  def denormalize_project
    return unless list_id && list_id_changed?
    self.project = list.project
  end

  def update_label_list
    return unless @labels
    label_list.clear
    @labels.each { |label| label_list << label }
  end

end
