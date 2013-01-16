class IntervalRecording::OfList < IntervalRecording::Base
  records :list

  delegate :cards, :card_history, :interval, :card_ids,
    to: :list

  def after_record
    cards.map { |card| card.record_interval(now) }
    card_count
  end

  def record_all_time_summary
    # card ids all time
    card_history.merge(card_ids) if card_ids.any?
  end

  def record_daily_summary
    # puts "list_id: #{list.id},#{date_key(today, :cumulative_total)} count: #{card_ids.count}, history #{card_history.size}"
    card_cumulative = card_history.size

    redis.multi do
      # card count for today
      interval.store(date_key(today, :card_count), card_count)

      # card ids for today
      interval.store(date_key(today, :card_ids), card_ids)

      # cumulative total by today
      interval.store(date_key(today, :cumulative_total), card_cumulative)
    end
  end

  def record_end_of_day_summary
    return if interval.has_key?(date_key(today))

    # end of day interval time stamp
    interval.store(date_key(today), now.to_i)

    # intervals all time
    interval.incr(:total, 1)

    # card count all time
    interval.incr(:card_count, card_count)
  end

  def card_count
    @card_count ||= cards.count
  end
end
