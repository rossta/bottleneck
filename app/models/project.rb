class Project < ActiveRecord::Base
  include TrelloFetchable
  attr_accessible :name, :uid, :trello_url, :trello_organization_id, :trello_closed

  belongs_to :trello_account
  belongs_to :owner, class_name: 'User', dependent: :destroy

  delegate :token, to: :trello_account, prefix: :trello, allow_nil: true

  trello_representative :trello_board, {
    name: :trello_name,
    url: :trello_url,
    organization_id: :trello_organization_id,
    closed: :trello_closed
  }

  def trello_board
    @trello_board ||= authorize { Trello::Board.find(uid) }
  end

end
