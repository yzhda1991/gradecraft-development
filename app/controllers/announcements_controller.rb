class AnnouncementsController < ApplicationController
  def index
    @announcements = Announcement.where(course_id: current_course.id)
  end
end
