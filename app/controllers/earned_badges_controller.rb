require_relative "../services/creates_earned_badge"

class EarnedBadgesController < ApplicationController
  # Earned badges are to badges what grades are to assignments - the record of
  # how what and how a student performed

  before_action :ensure_not_observer?
  before_action :ensure_staff?, except: [:new, :create]
  before_action :find_badge
  before_action :find_earned_badge, only: [:show, :edit, :update, :destroy ]
  before_action :use_current_course, only: [:show, :new, :edit, :mass_edit, :create, :update ]

  def index
    redirect_to badge_path(@badge)
  end

  def show
    @student = @earned_badge.student
  end

  def new
    @earned_badge = @badge.earned_badges.new course: @course
    authorize! :build, @earned_badge
    @students = earned_badge_students
  end

  def edit
    @students = @course.students.order_by_name
  end

  def create
    result = Services::CreatesEarnedBadge.call earned_badge_params.merge(awarded_by: current_user)

    if result.success?
      redirect_to badge_path(result.earned_badge.badge),
        notice: "The #{result.earned_badge.badge.name} #{term_for :badge} was successfully awarded to #{result.earned_badge.student.name}"
    else
      @earned_badge = result.earned_badge
      @students = earned_badge_students
      flash[:alert] = result.message
      render action: "new"
    end
  end

  def update
    if @earned_badge.update_attributes(
      earned_badge_params.merge(awarded_by: current_user)
    )
      if @badge.full_points?
        ScoreRecalculatorJob.new(user_id: @earned_badge.student_id,
                                 course_id: current_course.id).enqueue
      end
      expire_fragment "earned_badges"
      redirect_to badge_path(@badge),
        notice: "#{@earned_badge.student.name}'s #{@badge.name} #{term_for :badge} was successfully updated"
    else
      render action: "edit"
    end
  end

  # Quickly award a badge to multiple students
  def mass_edit
    @teams = @course.teams

    if params[:team_id].present?
      @team = @course.teams.find params[:team_id]
      @students = @course.students_being_graded_by_team(@team).order_by_name
    else
      @students = @course.students_being_graded.order_by_name
    end

    # build a new badge automatically if they can be earned at will
    if @badge.can_earn_multiple_times?
      @earned_badges = @students.map do |student|
        @badge.earned_badges.new(student: student, badge: @badge, awarded_by: current_user)
      end
    # otherwise build a new one only if it hasn't been earned
    else
      @earned_badges = @students.map do |student|
        @badge.earned_badges.where(student_id: student).first ||
          @badge.earned_badges.new(student: student, badge: @badge, awarded_by: current_user)
      end
    end
  end

  def mass_earn
    @valid_earned_badges ||= parse_valid_earned_badges
    make_badges_student_visible
    send_earned_badge_notifications
    if @badge.full_points?
      update_student_point_totals
    end
    handle_mass_update_redirect
  end

  def destroy
    @name = "#{@badge.name}"
    @student_name = "#{@earned_badge.student.name}"
    @earned_badge.destroy
    ScoreRecalculatorJob.new(user_id: @earned_badge.student_id, course_id: @earned_badge.course_id).enqueue
    expire_fragment "earned_badges"
    redirect_to @badge,
      notice: "The #{@badge.name} #{term_for :badge} has been taken away from #{@student_name}."
  end

  private

  def earned_badge_params
    params.require(:earned_badge).permit(:feedback, :student_id, :badge_id)
  end

  def earned_badge_students
    current_course.students_being_graded.order_by_name if current_user_is_staff?
    current_course.students_being_graded.order_by_name - [current_user]
  end

  def find_badge
    @badge = current_course.badges.find(params[:badge_id])
  end

  def find_earned_badge
    @earned_badge = @badge.earned_badges.find(params[:id])
  end

  def parse_valid_earned_badges
    params[:student_ids].inject([]) do |valid_earned_badges, student_id|
      earned_badge = EarnedBadge.create(student_id: student_id, badge: @badge, awarded_by: current_user)
      if earned_badge.valid?
        valid_earned_badges << earned_badge
      else
        logger.error earned_badge.errors.full_messages
      end
      valid_earned_badges
    end
  end

  def make_badges_student_visible
    @valid_earned_badges.each do |earned_badge|
      earned_badge.student_visible = true
      earned_badge.save
    end
  end

  def update_student_point_totals
    @valid_earned_badges.each do |earned_badge|
      ScoreRecalculatorJob.new(user_id: earned_badge.student.id,
        course_id: current_course.id).enqueue
      logger.info "Updated student scores to include EarnedBadge ##{earned_badge[:id]}"
    end
  end

  def send_earned_badge_notifications
    @valid_earned_badges.each do |earned_badge|
      EarnedBadgeAnnouncement.create earned_badge
      NotificationMailer.earned_badge_awarded(earned_badge).deliver_now
      logger.info "Sent an earned badge notification for EarnedBadge ##{earned_badge[:id]}"
    end
  end

  def handle_mass_update_redirect
    if @valid_earned_badges.any?
      redirect_to badge_path(@badge),
        notice: "The #{@badge.name} #{term_for :badge} was successfully awarded #{@valid_earned_badges.count} times"
    else
      redirect_to mass_edit_badge_earned_badges_path(@badge),
        notice: "No earned badges were sucessfully created."
    end
  end
end
