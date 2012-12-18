class CardInterval < ActiveRecord::Base
  belongs_to :list_interval
  belongs_to :card
  # attr_accessible :title, :body
end
