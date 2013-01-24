# Public: Convenience methods for calculating
# age and age relative results; Assumes presence
# of created_at timestamp
module Extensions
  module Age
    extend ActiveSupport::Concern

    def create_date
      created_at.to_date
    end

    def age_range(end_date = Clock.date)
      @age_range ||= Range.new(create_date, end_date)
    end

    def age_in_days
      (Clock.date - created_at.to_date).to_i
    end
  end
end
