class DropScoreLevelTable < ActiveRecord::Migration
  def change
    drop_table :score_levels
  end
end
