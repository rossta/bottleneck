class IntervalRecording::OfProject < IntervalRecording::Base
  records :project

  delegate :interval, :card_history, :list_history,
    :cards, :time_zone_now, :lists,
    to: :project

  def after_record
    lists.map { |list| list.record_interval(now) }
  end

  def record_all_time_summary
    # list ids all time
    list_history.merge(list_ids) if list_ids.any?

    # card ids all time
    card_history.merge(card_ids) if card_ids.any?
  end

  def record_daily_summary
    card_cumulative = card_history.size

    redis.pipelined do
      # list ids for today
      interval.store(date_key(today, :list_ids), list_ids)

      # card count for today
      interval.store(date_key(today, :card_count), card_count)

      # cumulative total by today
      interval.store(date_key(today, :cumulative_total), card_cumulative)
    end
  end

  def record_end_of_day_summary
    return if interval.has_key?(date_key(today))

    # end of day timestamp
    interval.store(date_key(today), now.to_i)

    # increment interval count
    interval.incr(:total, 1)

    # increment total card count
    interval.incr(:cards, card_count)
  end

  def card_count
    @count ||= cards.count
  end

  def list_ids
    @list_ids ||= project.list_ids
  end

  def card_ids
    @card_ids ||= project.card_ids
  end

end
