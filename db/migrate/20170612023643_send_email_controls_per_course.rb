class SendEmailControlsPerCourse < ActiveRecord::Migration[5.0]
  def change
    add_column :course_memberships, :email_announcements, :boolean, nil: false, default: true
    add_column :course_memberships, :email_badge_awards, :boolean, nil: false, default: true
    add_column :course_memberships, :email_grade_notifications, :boolean, nil: false, default: true
    add_column :course_memberships, :email_challenge_grade_notifications, :boolean, nil: false, default: true
  end
end
