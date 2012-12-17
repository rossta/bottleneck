class CreateLists < ActiveRecord::Migration
  def change
    create_table :lists do |t|
      t.string :name
      t.references :project
      t.string :uid
      t.string :trello_board_id
      t.boolean :trello_closed
      t.string :role

      t.timestamps
    end

    create_table :lists_roles, :id => false do |t|
      t.references :list
      t.references :role
    end

    add_index :lists_roles, [ :list_id, :role_id ]
  end
end
