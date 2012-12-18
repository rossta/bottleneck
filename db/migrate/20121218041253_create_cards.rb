class CreateCards < ActiveRecord::Migration
  def change
    create_table :cards do |t|
      t.references :list
      t.references :trello_account
      t.string :uid
      t.string :trello_name
      t.string :trello_short_id
      t.string :trello_closed
      t.string :trello_url
      t.string :trello_board_id
      t.string :trello_list_id
      t.integer :position
      t.timestamp :due_at

      t.timestamps
    end
  end
end
