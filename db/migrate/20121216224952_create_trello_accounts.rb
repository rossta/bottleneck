class CreateTrelloAccounts < ActiveRecord::Migration
  def change
    create_table :trello_accounts do |t|
      t.string :name
      t.string :token
      t.string :secret
      t.string :uid
      t.string :trello_avatar_id
      t.string :trello_url
      t.timestamps
    end
  end
end
