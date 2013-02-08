class CumulativeFlowSerializer < ActiveModel::Serializer
  attributes :id, :title, :start_date, :end_date, :collapsed, :series
end
