class AddTiersCountToMetrics < ActiveRecord::Migration
  def change
    add_column :metrics, :tiers_count, :integer, :default => 0
    Metric.reset_column_information
    Metric.all.each do |m|
      m.update_attribute :tiers_count, m.tiers.length
    end
  end
end
