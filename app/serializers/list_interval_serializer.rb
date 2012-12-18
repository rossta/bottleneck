class ListIntervalSerializer < ActiveModel::Serializer
  attributes :id, :recorded_at, :board_interval_id, :card_count
end
