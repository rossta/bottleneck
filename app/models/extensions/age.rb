# Public: Convenience methods for calculating
# age and age relative results; Assumes presence
# of created_at timestamp
module Extensions
  module Age
    extend ActiveSupport::Concern

    def create_date
      created_at.to_date
    end

    def age_range(end_time = Clock.time)
      @age_range ||= DateRange.new(
        start_time: created_at,
        end_time: end_time,
      )
    end

    def age_in_days
      (Clock.date - created_at.to_date).to_i
    end
  end
end
