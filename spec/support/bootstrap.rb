module Bootstrap
  extend self

  def project_for(user)
    require 'factory_girl'
    time_zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
    Time.use_zone(time_zone) do
      now = Time.now
      today = now.to_date
      midday = time_zone.parse("#{today} 12 PM")
      end_of_day = time_zone.parse("#{today} 11 PM")

      project = user.owned_projects.find_or_create_by_name("Scarecrow")
      project.time_zone = time_zone.name
      project.save!
      project.add_moderator(user) unless project.has_moderator?(user)

      # clear redis data
      project.clear_history

      list_config = [
        ['ready', List::BACKLOG],
        ['wip', List::WIP],
        ['review', List::WIP],
        ['approved', List::WIP],
        ['done', List::DONE]
      ]

      list_config.each_with_index do |config, i|
        name, role = *config
        list = project.lists.find_or_create_by_name(name.titleize)
        list.update_attributes(:position => (i + 1) * 100, :role => role)
        instance_variable_set("@#{name}", list)
      end

      # create 20 cards
      1.upto(20).each do |num|
        card = project.cards.find_or_create_by_name("Card #{num}")
        instance_variable_set("@card_#{num}", card)
      end

      days_ago = 8.days

      # Day 1
      @ready.cards    = [@card_1, @card_2, @card_3, @card_4, @card_5, @card_6, @card_7, @card_8, @card_9]
      @wip.cards      = [@card_10]
      @review.cards   = []
      @approved.cards = []
      @done.cards     = []

      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day   # 7.days

      # Day 1
      @ready.cards    = [@card_1, @card_2]
      @wip.cards      = [@card_3, @card_4, @card_5, @card_6, @card_7, @card_8]
      @review.cards   = [@card_9, @card_10]
      @approved.cards = []
      @done.cards     = []

      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day   # 6.days

      # Day 2
      @ready.cards    = [@card_12, @card_11, @card_1]
      @wip.cards      = [@card_2, @card_3, @card_4, @card_5, @card_6]
      @review.cards   = [@card_7, @card_8]
      @approved.cards = [@card_9]
      @done.cards     = [@card_10]

      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day  # 5.days

      # Day 3
      @ready.cards    = [@card_16, @card_15, @card_14, @card_12, @card_11]
      @wip.cards      = [@card_1, @card_2, @card_3, @card_4, @card_5]
      @review.cards   = [@card_6, @card_7, @card_8]
      @approved.cards = []
      @done.cards     = [@card_9, @card_10]

      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day   # 4.days

      # Day 4
      @ready.cards    = [@card_16, @card_15, @card_14, @card_13, @card_12]
      @wip.cards      = [@card_11, @card_1, @card_2, @card_3]
      @review.cards   = [@card_4, @card_5]
      @approved.cards = [@card_6]
      @done.cards     = [@card_7, @card_8, @card_9, @card_10]

      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day  # 3.days

      # Day 5
      @ready.cards    = [@card_16, @card_15, @card_14]
      @wip.cards      = [@card_13, @card_12, @card_11, @card_1]
      @review.cards   = [@card_2, @card_3, @card_4]
      @approved.cards = [@card_5]
      @done.cards     = [@card_6, @card_7, @card_8, @card_9, @card_10]

      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day  # 2.days

      # Day 6
      @ready.cards    = [@card_18, @card_17, @card_16, @card_15, @card_14]
      @wip.cards      = [@card_13, @card_12, @card_11, @card_1]
      @review.cards   = [@card_2]
      @approved.cards = [@card_3, @card_4]
      @done.cards     = [@card_5, @card_6, @card_7, @card_8]

      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day  # 1.day

      # Day 7
      @ready.cards    = [@card_20, @card_19, @card_18, @card_17, @card_16]
      @wip.cards      = [@card_15, @card_14, @card_13]
      @review.cards   = [@card_12, @card_11, @card_1]
      @approved.cards = [@card_2]
      @done.cards     = [@card_3, @card_4, @card_5, @card_6, @card_7, @card_8]

      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      # Day 8 (Today)
      @ready.cards    = [@card_20, @card_19, @card_18]
      @wip.cards      = [@card_17, @card_16, @card_15, @card_14]
      @review.cards   = [@card_13, @card_12, @card_11]
      @approved.cards = [@card_1]
      @done.cards     = [@card_2, @card_3, @card_4, @card_5, @card_6, @card_7, @card_8]

      project.reload
      project.record_interval(project.zone_time(midday))
      project.record_interval(project.zone_time(end_of_day))
    end
  end
end
