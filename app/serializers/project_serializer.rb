class ProjectSerializer < ActiveModel::Serializer
  embed :ids, include: true
  attributes :id, :name, :uid, :trello_url, :created_at, :updated_at, :time_zone

  has_many :lists
end
