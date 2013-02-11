class CumulativeFlowSerializer < ActiveModel::Serializer
  attributes :id, :name, :start_date, :end_date, :collapsed, :series
end
