class CreateCardIntervals < ActiveRecord::Migration
  def change
    create_table :card_intervals do |t|
      t.references :list_interval
      t.references :card

      t.timestamps
    end

    add_index :card_intervals, :list_interval_id
    add_index :card_intervals, :card_id
  end
end
