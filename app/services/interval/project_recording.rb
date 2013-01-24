class Interval::ProjectRecording < Interval::Base
  records :project

  delegate :interval, :card_history, :list_history,
    :cards, :zone_time_now, :lists, :current_cards,
    to: :project

  def after_record
    lists.map { |list| list.record_interval(now) }
  end

  def update_all_time_summary
    # list ids all time
    list_history.merge(list_ids) if list_ids.any?

    # card ids all time
    card_history.merge(card_ids) if card_ids.any?
  end

  def update_daily_summary
    # list ids for today
    interval.store(date_key(today, :list_ids), list_ids)

    # all count today
    interval.store(date_key(today, :card_count), card_count)

    # wip count today
    interval.store(date_key(today, :wip_count), wip_card_count)

    # done count today
    interval.store(date_key(today, :done_count), done_card_count)

    # lead time today
    interval.store(date_key(today, :lead_time), lead_time)
  end

  def record_end_of_day_summary
    return if interval.has_key?(date_key(today))

    # end of day timestamp
    interval.store(date_key(today), now.to_i)

    # increment age
    interval.incr(:total, 1)

    # store total card count
    interval.store(:cards, cumulative_card_count)
  end

  def card_count
    @count ||= current_cards.count
  end

  def wip_card_count
    @wip_card_count ||= current_cards.joins(:list).merge(List.wip).count
  end

  def done_card_count
    @done_card_count ||= lists.done.map { |l| l.cumulative_total(today) }.inject(&:+)
  end

  def lead_time
    @lead_time ||= begin
      days_ago = 0
      done      = project.done_count(today)
      capacity  = project.capacity_count(today)

      # back track one day at a time until capacity
      # was less than or equal to currently done
      # "times out" over 100
      while done < capacity
        days_ago += 1
        break if days_ago > 100
        capacity = project.capacity_count(today - days_ago.days)
      end

      days_ago
    end
  end

  def cumulative_card_count
    card_history.size
  end

  def list_ids
    @list_ids ||= project.list_ids
  end

  def card_ids
    @card_ids ||= project.card_ids
  end

end
