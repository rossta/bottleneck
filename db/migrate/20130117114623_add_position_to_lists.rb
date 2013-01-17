class AddPositionToLists < ActiveRecord::Migration
  def change
    add_column :lists, :position, :integer

    add_index :lists, :position
  end
end
