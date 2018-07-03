class AnnouncementState < ApplicationRecord
  belongs_to :announcement
  belongs_to :user

  scope :for_course, ->(course) do
    joins(:announcement).where(announcements: {course_id: course.id})
  end
  scope :for_user, ->(user) { where(user_id: user.id) }
end
