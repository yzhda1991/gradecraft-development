class AddSeeMoreLinktoCourseSettings < ActiveRecord::Migration
  def change
    add_column :courses, :show_see_details_link_in_timeline, :boolean, default: true
  end
end
