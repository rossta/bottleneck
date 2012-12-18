class ListSerializer < ActiveModel::Serializer
  attributes :id, :name, :project_id, :role
end
