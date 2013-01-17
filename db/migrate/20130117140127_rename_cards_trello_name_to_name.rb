class RenameCardsTrelloNameToName < ActiveRecord::Migration
  def change
    rename_column :cards, :trello_name, :name
  end
end
