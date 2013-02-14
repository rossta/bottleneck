class ProjectSummarySerializer < ActiveModel::Serializer
  attributes :project_id, :name, :time_zone, :date,
    :time_zone, :current_wip, :starting_wip, :lead_time, :arrival_rate,
    :capacity, :average_wip, :average_lead_time, :average_arrival_rate

end
