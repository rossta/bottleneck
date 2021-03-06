class Interval::ListRecording < Interval::Base
  records :list

  delegate :cards, :card_history, :interval, :card_ids,
    to: :list

  def after_record
    cards.map { |card| card.record_interval(now) }
    card_count
  end

  def update_all_time_summary
    # card ids all time
    card_history.merge(card_ids) if card_ids.any?
  end

  def update_daily_summary
    card_cumulative = card_history.size

    # card count for today
    interval.store(date_key(today, :card_count), card_count)

    # card ids for today
    interval.store(date_key(today, :card_ids), card_ids)

    # card label counts for today
    cards.tag_counts_on(:labels).each do |label|
      interval.store(date_key(today, :card_count, label.name), label.count)
    end

    # cumulative total by today
    interval.store(date_key(today, :cumulative_total), card_cumulative)
  end

  def record_end_of_day_summary
    return if interval.has_key?(date_key(today))

    # end of day interval time stamp
    interval.store(date_key(today), now.to_i)

    # intervals all time
    interval.incr(:total, 1)

    # card count all time
    interval.store(:card_count, card_count)
  end

  def card_count
    @card_count ||= cards.count
  end
end
