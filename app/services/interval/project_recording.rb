class Interval::ProjectRecording < Interval::Base
  records :project

  delegate :store_interval, :incr_interval, :interval_key?,
    :card_history, :list_history,
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
    store_interval(date_key(today, :list_ids), list_ids)

    # all count today
    store_interval(date_key(today, :card_count), card_count)

    # card label counts for today
    card_label_counts.each do |label|
      store_interval(date_key(today, :card_count, label.name), label.count)
    end

    # backlog count today
    store_interval(date_key(today, :backlog_count), backlog_cards.count)

    # wip count today
    store_interval(date_key(today, :wip_count), wip_cards.count)

    # done count today
    store_interval(date_key(today, :done_count), done_card_count)

    # card label counts for today
    card_label_counts.each do |label|
      store_interval(date_key(today, :card_count, label.name), label.count)
    end

    # lead time today
    store_interval(date_key(today, :lead_time), lead_time)
  end

  def record_end_of_day_summary
    return if interval_key?(date_key(today))

    # end of day timestamp
    store_interval(date_key(today), now.to_i)

    # increment age
    incr_interval(:total, 1)

    # store total card count
    store_interval(:cards, cumulative_card_count)
  end

  def card_count
    @count ||= current_cards.count
  end

  def card_label_counts
    @card_label_counts ||= current_cards.tag_counts_on(:labels)
  end

  def backlog_cards
    @backlog_cards ||= current_cards.joins(:list).merge(List.backlog)
  end

  def wip_cards
    @wip_cards ||= current_cards.joins(:list).merge(List.wip)
  end

  def done_card_count
    @done_card_count ||= lists.done.map { |l| l.cumulative_total(today) }.inject(&:+)
  end

  def lead_time
    @lead_time ||= LeadTime.days(project, today)
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
