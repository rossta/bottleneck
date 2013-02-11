module Bootstrap
  extend self

  def project_for(user)
    require 'factory_girl'
    project_name = "Scarecrow"
    time_zone = ActiveSupport::TimeZone['Eastern Time (US & Canada)']
    Time.use_zone(time_zone) do
      now = Time.now
      today = now.to_date
      midday = time_zone.parse("#{today} 12 PM")
      end_of_day = time_zone.parse("#{today} 11 PM")

      Rails.logger.info "#{project_name}: set up project"

      project = user.owned_projects.find_or_create_by_name(project_name)
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

      Rails.logger.info "#{project_name}: set up lists"

      list_config.each_with_index do |config, i|
        name, role = *config
        list = project.lists.find_or_create_by_name(name.titleize)
        list.update_attributes(:position => (i + 1) * 100, :role => role)
        instance_variable_set("@#{name}", list)
      end

      Rails.logger.info "#{project_name}: set up cards"
      label_set = %w[ Bug Chore Story Story ]
      1.upto(30).each do |num|
        card = project.cards.find_or_initialize_by_name("Card #{num}")
        card.label_list = label_set.sample
        instance_variable_set("@card_#{num}", card)
        card.save
      end

      Rails.logger.info "#{project_name}: record from 15 days ago"
      days_ago = 15.days

      # Day 0, Sunday
      @ready.cards    = [@card_1, @card_2, @card_3, @card_4, @card_5, @card_6, @card_7, @card_8, @card_9]
      @wip.cards      = [@card_10]
      @review.cards   = []
      @approved.cards = []
      @done.cards     = []

      Rails.logger.info "#{project_name}: recording #{project.zone_time(end_of_day - days_ago).to_date.to_s(:long)}, #{days_ago/1.day} days ago"
      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day

      # Day 1, Monday
      @ready.cards    = [@card_1, @card_2]
      @wip.cards      = [@card_3, @card_4, @card_5, @card_6, @card_7, @card_8]
      @review.cards   = [@card_9, @card_10]
      @approved.cards = []
      @done.cards     = []

      Rails.logger.info "#{project_name}: recording #{project.zone_time(end_of_day - days_ago).to_date.to_s(:long)}, #{days_ago/1.day} days ago"
      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day

      # Day 2, Tuesday
      @ready.cards    = [@card_12, @card_11, @card_1]
      @wip.cards      = [@card_2, @card_3, @card_4, @card_5, @card_6]
      @review.cards   = [@card_7, @card_8]
      @approved.cards = [@card_9]
      @done.cards     = [@card_10]

      Rails.logger.info "#{project_name}: recording #{project.zone_time(end_of_day - days_ago).to_date.to_s(:long)}, #{days_ago/1.day} days ago"
      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day

      # Day 3, Wednesday
      @ready.cards    = [@card_16, @card_15, @card_14, @card_12, @card_11]
      @wip.cards      = [@card_1, @card_2, @card_3, @card_4, @card_5]
      @review.cards   = [@card_6, @card_7, @card_8]
      @approved.cards = []
      @done.cards     = [@card_9, @card_10]

      Rails.logger.info "#{project_name}: recording #{project.zone_time(end_of_day - days_ago).to_date.to_s(:long)}, #{days_ago/1.day} days ago"
      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day

      # Day 4, Thursday
      @ready.cards    = [@card_16, @card_15, @card_14, @card_13, @card_12]
      @wip.cards      = [@card_11, @card_1, @card_2, @card_3]
      @review.cards   = [@card_4, @card_5]
      @approved.cards = [@card_6]
      @done.cards     = [@card_7, @card_8, @card_9, @card_10]

      Rails.logger.info "#{project_name}: recording #{project.zone_time(end_of_day - days_ago).to_date.to_s(:long)}, #{days_ago/1.day} days ago"
      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day

      # Day 5, Friday
      @ready.cards    = [@card_16, @card_15, @card_14]
      @wip.cards      = [@card_13, @card_12, @card_11, @card_1]
      @review.cards   = [@card_2, @card_3, @card_4]
      @approved.cards = [@card_5]
      @done.cards     = [@card_6, @card_7, @card_8, @card_9, @card_10]

      Rails.logger.info "#{project_name}: recording #{project.zone_time(end_of_day - days_ago).to_date.to_s(:long)}, #{days_ago/1.day} days ago"
      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day

      # Day 6, Saturday

      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day

      # Day 7, Sunday

      Rails.logger.info "#{project_name}: recording #{project.zone_time(end_of_day - days_ago).to_date.to_s(:long)}, #{days_ago/1.day} days ago"
      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day  # 6.days

      # Day 8, Monday
      @ready.cards    = [@card_18, @card_17, @card_16, @card_15, @card_14]
      @wip.cards      = [@card_13, @card_12, @card_11, @card_1]
      @review.cards   = [@card_2]
      @approved.cards = [@card_3, @card_4]
      @done.cards     = [@card_5]

      Rails.logger.info "#{project_name}: recording #{project.zone_time(end_of_day - days_ago).to_date.to_s(:long)}, #{days_ago/1.day} days ago"
      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day  # 6.days

      # Day 9, Tuesday
      @ready.cards    = [@card_20, @card_19, @card_18, @card_17, @card_16]
      @wip.cards      = [@card_15, @card_14, @card_13]
      @review.cards   = [@card_12, @card_11, @card_1]
      @approved.cards = [@card_2]
      @done.cards     = [@card_3, @card_4, @card_5]

      Rails.logger.info "#{project_name}: recording #{project.zone_time(end_of_day - days_ago).to_date.to_s(:long)}, #{days_ago/1.day} days ago"
      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day  # 5.days

      # Day 10, Wednesday
      @ready.cards    = [@card_23, @card_22, @card_21]
      @wip.cards      = [@card_20, @card_19, @card_18, @card_17]
      @review.cards   = [@card_16, @card_15, @card_14]
      @approved.cards = [@card_13]
      @done.cards     = [@card_12, @card_11, @card_1, @card_2, @card_3, @card_4, @card_5]

      Rails.logger.info "#{project_name}: recording #{project.zone_time(end_of_day - days_ago).to_date.to_s(:long)}, #{days_ago/1.day} days ago"
      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day  # 5.days

      # Day 11, Thursday
      @ready.cards    = [@card_25, @card_24, @card_23, @card_22, @card_21]
      @wip.cards      = [@card_20, @card_17]
      @review.cards   = [@card_19, @card_18, @card_16]
      @approved.cards = [@card_15, @card_14]
      @done.cards     = [@card_13, @card_12, @card_11, @card_1, @card_2, @card_3, @card_4, @card_5]

      Rails.logger.info "#{project_name}: recording #{project.zone_time(end_of_day - days_ago).to_date.to_s(:long)}, #{days_ago/1.day} days ago"
      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day  # 5.days

      # Day 12, Friday
      @ready.cards    = [@card_28, @card_27, @card_26, @card_25, @card_24, @card_23]
      @wip.cards      = [@card_22, @card_21, @card_20, @card_17]
      @review.cards   = [@card_19, @card_18]
      @approved.cards = [@card_15]
      @done.cards     = [@card_16, @card_14, @card_13, @card_12, @card_11, @card_1, @card_2, @card_3, @card_4, @card_5]

      Rails.logger.info "#{project_name}: recording #{project.zone_time(end_of_day - days_ago).to_date.to_s(:long)}, #{days_ago/1.day} days ago"
      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day  # 5.days

      # Day 13, Saturday
      Rails.logger.info "#{project_name}: recording #{project.zone_time(end_of_day - days_ago).to_date.to_s(:long)}, #{days_ago/1.day} days ago"
      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day  # 5.days

      # Day 14, Sunday
      Rails.logger.info "#{project_name}: recording #{project.zone_time(end_of_day - days_ago).to_date.to_s(:long)}, #{days_ago/1.day} days ago"
      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))

      days_ago -= 1.day  # 5.days

      # Day 15, Monday
      @ready.cards    = [@card_28, @card_27, @card_26, @card_25, @card_24]
      @wip.cards      = [@card_23, @card_22, @card_17]
      @review.cards   = [@card_21, @card_20]
      @approved.cards = []
      @done.cards     = [@card_19, @card_18, @card_15]

      Rails.logger.info "#{project_name}: recording #{project.zone_time(end_of_day - days_ago).to_date.to_s(:long)}, #{days_ago/1.day} days ago"
      project.reload
      project.record_interval(project.zone_time(midday - days_ago))
      project.record_interval(project.zone_time(end_of_day - days_ago))
    end
  end
end
