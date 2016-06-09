class DropTimelineFromCourseMOdel < ActiveRecord::Migration
  def change
    remove_column :courses, :use_timeline
    remove_column :courses, :show_see_details_link_in_timeline
  end
end
