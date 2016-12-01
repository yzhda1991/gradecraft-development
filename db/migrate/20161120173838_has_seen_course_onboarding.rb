class HasSeenCourseOnboarding < ActiveRecord::Migration[5.0]
  def change
    add_column :course_memberships, :has_seen_course_onboarding, :boolean, default: true, nil: false
  end
end
