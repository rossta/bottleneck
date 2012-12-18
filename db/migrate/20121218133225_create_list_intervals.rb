class CreateListIntervals < ActiveRecord::Migration
  def change
    create_table :list_intervals do |t|
      t.references :list
      t.references :board_interval
      t.timestamp :recorded_at
      t.integer :card_count

      t.timestamps
    end

    add_index :list_intervals, :board_interval_id
    add_index :list_intervals, :list_id
  end
end
