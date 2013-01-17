class CardSerializer < ActiveModel::Serializer
  attributes :id, :trello_short_id, :name, :due, :trello_closed, :trello_url, :trello_board_id, :trello_member_ids, :trello_list_id, :position
end
