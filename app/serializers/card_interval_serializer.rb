class CardIntervalSerializer < ActiveModel::Serializer
  attributes :id
  has_one :list_interval
  has_one :card
end
