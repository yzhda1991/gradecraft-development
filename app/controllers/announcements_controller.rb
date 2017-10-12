class AnnouncementsController < ApplicationController
  include AnnouncementsHelper

  def index
    @announcements = Announcement.where(course_id: current_course.id,
                                        recipient_id: [nil, current_user.id])
  end

  def show
    @announcement = Announcement.find params[:id]
    if @announcement.course == current_course
      authorize! :show, @announcement
    else
      redirect_to dashboard_path, notice: "It looks like that announcement isn't for this course. Try switching courses to #{view_context.link_to(@announcement.course.name, change_course_path(@announcement.course))}."
    end
    @announcement.mark_as_read! current_user
    Rails.cache.delete unread_cache_key(current_user, @announcement.course)
  end

  def new
    @announcement = Announcement.new course_id: current_course.id
    authorize! :create, @announcement
  end

  def create
    @announcement = Announcement.new(announcement_params
      .merge(course_id: current_course.id, author_id: current_user.id))
    authorize! :create, @announcement
    if @announcement.save
      @announcement.deliver!
      redirect_to announcements_path,
        # rubocop:disable AndOr
        notice: "Announcement created and sent." and return
    end
    render :new
  end

  # DELETE /announcements/:id
  def destroy
    @announcement = Announcement.find params[:id]
    authorize! :destroy, @announcement
    @title = @announcement.title
    @announcement.destroy
    redirect_to announcements_url, notice: "Announcement #{@title} successfully deleted"
  end

  private

  def announcement_params
    params.require(:announcement).permit(:author_id, :body, :course_id, :title)
  end
end
