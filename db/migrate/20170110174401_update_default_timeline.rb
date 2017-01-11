class UpdateDefaultTimeline < ActiveRecord::Migration[5.0]
  def change
    change_column :assignments, :include_in_timeline, :boolean, default: true, null: false
    change_column :course_memberships, :has_seen_course_onboarding, :boolean, default: false
  end
end
