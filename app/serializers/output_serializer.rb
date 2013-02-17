class OutputSerializer < ActiveModel::Serializer
  attributes :project_id, :name, :time_zone, :start_date, :end_date, :series
end
