class AddProjectIdToCards < ActiveRecord::Migration
  def change
    add_column :cards, :project_id, :integer

    add_index :cards, :project_id
  end
end
