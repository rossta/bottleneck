class ListInterval < ActiveRecord::Base
  belongs_to :list
  belongs_to :board_interval
  has_many :card_intervals, dependent: :destroy
  has_many :cards, through: :card_intervals

  delegate :recorded_at, to: :board_interval

  def self.for_lists(lists)
    lists.map do |list|
      new do |li|
        li.list = list
      end
    end
  end

  def record
    self.cards = list.cards
    self.card_count = self.cards.count
    save!
  end
end
