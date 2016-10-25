class RenameCourseAnalytics < ActiveRecord::Migration
  def change
    rename_column :courses, :hide_analytics, :show_analytics
    change_column :courses, :show_analytics, :boolean, default: true
  end
end
