class AnnouncementsController < ApplicationController
  def index
    @title = "Announcements"
    @announcements = Announcement.where(course_id: current_course.id)
  end

  def new
    @title = "Create a New Announcement"
    @announcement = Announcement.new course_id: current_course.id
  end
end
