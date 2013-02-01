class ProjectSerializer < ActiveModel::Serializer
  attributes :id, :name, :uid, :trello_url, :created_at, :updated_at, :time_zone
end
