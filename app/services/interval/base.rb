module Interval
  class Base
    include RedisKeys

    class_attribute :recording_subject

    attr_accessor :of, :at
    alias_method :now, :at
    alias_method :subject, :of

    def self.records(method_name)
      define_method(method_name) { of }
    end

    def initialize(attrs = {})
      @of = attrs[:of]
      @at = attrs[:at]
    end

    def record
      update_all_time_summary
      update_daily_summary
      record_end_of_day_summary if near_end_of_day?

      after_record
    end

    def today
      now.to_date
    end

    def near_end_of_day?
      hrs_til_midnight <= 1
    end

    def hrs_til_midnight
      ((now.end_of_day - now) / 1.hour).to_i
    end

    protected

    def update_all_time_summary; end
    def update_daily_summary; end
    def record_end_of_day_summary; end
    def after_record; end
  end
end
