class DropMetricBadges < ActiveRecord::Migration
  def change
    drop_table :metric_badges
  end
end
