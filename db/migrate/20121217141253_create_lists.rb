class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.string :name
      t.references :project
      t.references :trello_account
      t.string :uid
      t.string :trello_board_id
      t.boolean :trello_closed
      t.string :role

      t.timestamps
    end

    add_index :lists, :project_id
    add_index :lists, :trello_account_id
  end
end
