class Interval::CardRecording < Interval::Base
  records :card

  delegate :list, :list_history, :interval, :list_id,
    to: :card

  def update_all_time_summary
    # all time list ids
    list_history << list_id if list_id
  end

  def update_daily_summary
    # record list_id each day
    interval.store(date_key(today, :list_id), list_id)

    # update most recent list_id each day
    interval.store(:last_list_id, list_id)
  end

  def record_end_of_day_summary
    return if interval.has_key?(date_key(today))

    # timestamp
    interval.store(date_key(today), now.to_i)

    # increment age
    interval.incr(:total, 1)

    # increment total for list_id
    interval.incr(redis_key(:list_total, list_id), 1)

    # increment total for list role
    interval.incr(redis_key(:state, card.state.downcase), 1)
  end
end
