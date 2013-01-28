class TrelloAccount < ActiveRecord::Base
  include Extensions::TrelloFetchable
  attr_accessible :name, :token, :secret

  trello_api_adapter :trello_member, {
    username:  :name,
    id:        :uid,
    avatar_id: :trello_avatar_id,
    url:       :trello_url
  }

  has_many :projects

  def self.fetch(trello_name)
    Trello::Member.find(trello_name)
  end

  def client
    @client ||= Trello::Client.new({
      :consumer_key => ENV['TRELLO_USER_KEY'],
      :consumer_secret => ENV['TRELLO_USER_SECRET'],
      :oauth_token => token,
      :oauth_token_secret => secret
    })
  end

  def trello_member
    @trello_member ||= client.find(:members, 'me')
  end

  def trello_boards
    @trello_boards ||= trello_member.boards
  end

  def trello_token; token; end
  def trello_secret; secret; end

end
