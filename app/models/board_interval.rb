class BoardInterval < ActiveRecord::Base
  attr_accessible :recorded_at

  belongs_to :project
  delegate :lists, to: :project

  has_many :list_intervals, dependent: :destroy
  has_many :lists, through: :list_intervals


  def self.record(project)
    interval = BoardInterval.find_or_initialize_by_recorded_at(project.record_at)
    interval.project = project
    interval.list_intervals = ListInterval.from_lists(project.lists)
    interval.record
  end

  def record
    list_intervals.map(&:record)
    save!
  end

end
