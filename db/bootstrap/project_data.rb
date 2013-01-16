time_zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
Time.use_zone(time_zone) do
  now = Time.now
  today = now.to_date
  midday = time_zone.parse("#{today} 12 PM")
  end_of_day = time_zone.parse("#{today} 11 PM")

  rossta = User.find_by_name("rossta")
  project = rossta.owned_projects.find_or_create_by_name("Scarecrow")
  project.time_zone = time_zone.name
  project.save!
  project.add_moderator(rossta) unless project.has_moderator?(rossta)

  # clear redis data
  project.interval.clear
  project.card_history.clear
  project.list_history.clear

  %w[ ideas ready wip review done ].each do |name|
    list = project.lists.find_or_create_by_name(name.titleize)
    instance_variable_set("@#{name}", list)
    list.interval.clear
    list.card_history.clear
  end

  # create 10 cards
  1.upto(10).each do |num|
    card = project.cards.find_or_create_by_trello_name("Card #{num}")
    instance_variable_set("@card_#{num}", card)
    card.interval.clear
    card.list_history.clear
  end

  # Day 1
  @ideas.cards  = [@card_1, @card_2]
  @ready.cards  = [@card_3, @card_4, @card_5, @card_6, @card_7, @card_8]
  @wip.cards    = [@card_9, @card_10]
  @review.cards = []
  @done.cards   = []

  project.reload
  project.record_interval(project.zone_time(midday - 4.days))
  project.record_interval(project.zone_time(end_of_day - 4.days))

  # Day 2
  @ideas.cards  = [@card_1]
  @ready.cards  = [@card_2, @card_3, @card_4, @card_5, @card_6]
  @wip.cards    = [@card_7, @card_8]
  @review.cards = [@card_9]
  @done.cards   = [@card_10]

  project.reload
  project.record_interval(project.zone_time(midday - 3.days))
  project.record_interval(project.zone_time(end_of_day - 3.days))

  # Day 3
  @ideas.cards  = []
  @ready.cards  = [@card_1, @card_2, @card_3, @card_4, @card_5]
  @wip.cards    = [@card_6, @card_7, @card_8]
  @review.cards = []
  @done.cards   = [@card_9, @card_10]

  project.reload
  project.record_interval(project.zone_time(midday - 2.days))
  project.record_interval(project.zone_time(end_of_day - 2.days))

  # Day 4
  @ideas.cards  = []
  @ready.cards  = [@card_1, @card_2, @card_3]
  @wip.cards    = [@card_4, @card_5]
  @review.cards = [@card_6]
  @done.cards   = [@card_7, @card_8, @card_9, @card_10]

  project.reload
  project.record_interval(project.zone_time(midday - 1.day))
  project.record_interval(project.zone_time(end_of_day - 1.day))

  # Day 5
  @ideas.cards  = []
  @ready.cards  = [@card_1,]
  @wip.cards    = [@card_2, @card_3, @card_4]
  @review.cards = [@card_5]
  @done.cards   = [@card_6, @card_7, @card_8, @card_9, @card_10]

  project.reload
  project.record_interval(project.zone_time(midday))
  project.record_interval(project.zone_time(end_of_day))

  # Day 6
  @ideas.cards  = []
  @ready.cards  = [@card_1]
  @wip.cards    = [@card_2]
  @review.cards = [@card_3, @card_4]
  @done.cards   = [@card_5, @card_6, @card_7, @card_8]

  project.reload
  project.record_interval(project.zone_time(midday + 1.day))
  project.record_interval(project.zone_time(end_of_day + 1.day))
end
