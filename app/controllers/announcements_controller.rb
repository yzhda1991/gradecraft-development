class AnnouncementsController < ApplicationController
  def index
    @title = "Announcements"
    @announcements = Announcement.where(course_id: current_course.id)
  end

  def show
    @announcement = Announcement.find params[:id]
    @title = @announcement.title
  end

  def new
    @title = "Create a New Announcement"
    @announcement = Announcement.new course_id: current_course.id
  end

  def create
    announcement_params = params[:announcement]
      .merge({ course_id: current_course.id, author_id: current_user.id })
    @announcement = Announcement.new announcement_params
    if @announcement.save
      @announcement.deliver!
      redirect_to announcements_path, notice: "Announcement created and sent." and return
    end

    @title = "Create a New Announcement"
    render :new
  end
end
