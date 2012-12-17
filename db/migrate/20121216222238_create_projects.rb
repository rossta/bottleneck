class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
      t.string :uid
      t.string :trello_url
      t.integer :trello_organization_id
      t.boolean :trello_closed
      t.timestamps
    end
  end
end
