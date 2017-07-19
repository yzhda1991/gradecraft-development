class BadgesController < ApplicationController

  before_action :ensure_not_observer?, except: [:index, :show]
  before_action :ensure_staff?, except: [:index, :show]
  before_action :find_badge, only: [:show, :edit, :update, :destroy]
  before_action :use_current_course, only: [:index, :show, :new, :edit]

  # GET /badges
  def index
    render Badges::IndexPresenter.build({
      title: term_for(:badges),
      badges: @course.badges.ordered,
      student: current_student
    })
  end

  # GET /badges/:id
  def show
    render Badges::ShowPresenter.build({
      course: @course,
      badge: @badge,
      student: current_student,
      teams: @course.teams,
      params: params
    })
  end

  def new
    @badge = @course.badges.new
  end

  def edit
  end

  def new_edit
    @badge = Badge.find(params[:badge_id])
  end

  def create
    @badge = current_course.badges.new(badge_params)

    if @badge.save
      redirect_to @badge,
        notice: "#{@badge.name} #{term_for :badge} successfully created"
    else
      render action: "new"
    end
  end

  def update
    if @badge.update_attributes(badge_params)
      redirect_to badges_path,
        notice: "#{@badge.name} #{term_for :badge} successfully updated"
    else
      render action: "edit"
    end
  end

  def destroy
    @name = @badge.name
    @badge.destroy
    redirect_to badges_path,
      notice: "#{@name} #{term_for :badge} successfully deleted"
  end

  def export_structure
    course = current_user.courses.find_by(id: params[:id])
    respond_to do |format|
      format.csv { send_data BadgeExporter.new.export(course), filename: "#{ course.name } #{ (term_for :badges).titleize } - #{ Date.today }.csv" }
    end
  end

  private

  def badge_params
    params.require(:badge).permit(:name, :description, :icon, :visible, :full_points,
      :can_earn_multiple_times, :earned_badges, :earned_badges_attributes,
      :position, :visible_when_locked, :course_id, :course, :show_name_when_locked,
      :show_points_when_locked, :show_description_when_locked, :student_awardable,
      unlock_conditions_attributes: [:id, :unlockable_id, :unlockable_type, :condition_id,
        :condition_type, :condition_state, :condition_value, :condition_date, :_destroy],
      badge_files_attributes: [:id, file: []])
  end

  def find_badge
    @badge = current_course.badges.find(params[:id])
  end
end
