module TrelloFetchable
  extend ActiveSupport::Concern

  included do
    class_attribute :trello_representative_method
    class_attribute :trello_mapping
    class_attribute :trello_token_method
    self.trello_mapping = {}
  end

  def trello_mapping
    self.class.trello_mapping
  end

  def trello_representative
    send(self.class.trello_representative_method)
  end

  def fetch
    self.tap do
      trello_mapping.each do |trello_method, method|
        send("#{method}=", trello_representative.send(trello_method))
      end
    end
  end

  def trello_token
    send(trello_token_method)
  end

  def authorize(&block)
    TrelloAuthorization.session(trello_token, nil, &block)
  end

  private

  def trello_token_method
    self.class.trello_token_method || :trello_token
  end

  module ClassMethods
    def trello_representative(name, mapping = {})
      self.trello_representative_method = name
      self.trello_mapping.merge!(mapping)
    end

    def trello_token(method)
      self.trello_token_method = method
    end
  end
end
