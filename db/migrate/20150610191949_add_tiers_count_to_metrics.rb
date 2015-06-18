class AddTiersCountToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :tiers_count, :integer, :default => 0
  end
end
