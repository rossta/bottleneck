class Output
  include Virtus

  attribute :start_time
  attribute :end_time

  attr_accessor :project

  def title
    "Output: #{days_trailing}"
  end

  def interval_in_days
    ((end_time - start_time) / 1.day).to_i
  end

  def days_trailing
    "#{interval_in_days} days trailing"
  end

  def to_json
    [
      # WIP,
      # {
      #   :name => 'Total WIP',
      #   :data => ListInterval.new(list, beg_of_period, end_of_period).data,
      #   :position => list.position
      # },
      # {
      #   :name => 'Lead Time',
      #   :data => ListInterval.new(list, beg_of_period, end_of_period).data,
      #   :position => list.position
      # },
      # {
      #   :name => 'Throughout',
      #   :data => ListInterval.new(list, beg_of_period, end_of_period).data,
      #   :position => list.position
      # }
    ]
  end

end
