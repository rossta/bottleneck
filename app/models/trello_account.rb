class TrelloAccount < ActiveRecord::Base
  include TrelloFetchable
  attr_accessible :name, :token, :secret

  trello_representative :trello_member, {
    username:  :name,
    id:        :uid,
    avatar_id: :trello_avatar_id,
    url:       :trello_url
  }

  trello_token :token

  has_many :projects

  def self.fetch(trello_name)
    Trello::Member.find(trello_name)
  end

  def trello_member
    @trello_member ||= authorize { Trello::Member.find(name) }
  end

  def trello_boards
    @trello_boards ||= authorize { trello_member.boards }
  end

end
