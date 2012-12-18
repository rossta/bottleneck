class CreateBoardIntervals < ActiveRecord::Migration
  def change
    create_table :board_intervals do |t|
      t.references :project
      t.timestamp :recorded_at
      t.timestamps
    end

    add_index :board_intervals, :project_id
  end
end
