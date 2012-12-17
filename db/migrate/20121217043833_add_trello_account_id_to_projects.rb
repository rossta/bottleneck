class AddTrelloAccountIdToProjects < ActiveRecord::Migration
  def change
    add_column :projects, :trello_name, :string
    add_column :projects, :owner_id, :integer
    add_column :projects, :trello_account_id, :integer

    add_index :projects, :owner_id
  end
end
