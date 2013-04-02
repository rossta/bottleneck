class AddUserIdToTrelloAccountId < ActiveRecord::Migration
  def change
    add_column :trello_accounts, :user_id, :integer
  end
end
