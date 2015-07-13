class HideAnalyticsAtClassAndAssignmentLevel < ActiveRecord::Migration
  def change
  	add_column :courses, :hide_analytics, :boolean
  	add_column :assignments, :hide_analytics, :boolean
  end
end
