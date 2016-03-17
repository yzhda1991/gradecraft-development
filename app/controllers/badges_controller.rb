class BadgesController < ApplicationController
  include SortsPosition

  before_filter :ensure_staff?, except: [:predictor_data, :predict_times_earned]
  before_filter :ensure_student?, only: [:predict_times_earned]
  before_action :find_badge, only: [:show, :edit, :update, :destroy]

  def index
    @title = "#{term_for :badges}"
    @badges = current_course.badges
  end

  def show
    @title = @badge.name
    @earned_badges = @badge.earned_badges
    @teams = current_course.teams
    if params[:team_id].present?
      @team = @teams.find_by(id: params[:team_id]) if params[:team_id]
      students = current_course.students_being_graded_by_team(@team)
    else
      students = current_course.students_being_graded
    end
    @students = students
  end

  def new
    @title = "Create a New #{term_for :badge}"
    @badge = current_course.badges.new
  end

  def edit
    @title = "Editing #{@badge.name}"
  end

  def create
    @badge = current_course.badges.new(params[:badge])

    if @badge.save
      redirect_to @badge, notice: "#{@badge.name} #{term_for :badge} successfully created"
    else
      render action: "new"
    end
  end

  def update
    if @badge.update_attributes(params[:badge])
      redirect_to badges_path, notice: "#{@badge.name} #{term_for :badge} successfully updated"
    else
      render action: "edit"
    end
  end

  def sort
    sort_position_for :badge
  end

  def destroy
    @name = @badge.name
    @badge.destroy

    respond_to do |format|
      format.html { redirect_to badges_path, notice: "#{@name} #{term_for :badge} successfully deleted" }
    end
  end

  def predict_times_earned
    @badge = current_course.badges.find(params[:badge_id])
    @badgePrediction =
      PredictedEarnedBadge.where(student: current_student, badge: @badge).first
    @badgePrediction.times_earned = params[:times_earned]

    # save the prediction and cache the outcome
    @prediction_saved = @badgePrediction.save

    # create a predictor event in mongo to keep track of what happened
    PredictorEventJob.new(data: badge_predictor_event_attrs).enqueue

    respond_to do |format|
      format.json do
        if @prediction_saved
          render json: {
            id: @badge.id,
            times_earned: @badgePrediction.times_earned
          }
        else
          render json: {
            errors:  @badgePrediction.errors.full_messages
            },
            status: 400
        end
      end
    end
  end

  def predictor_data
    if current_user.is_student?(current_course)
      @student = current_student
      @update_badges = true
    elsif params[:id]
      @student = User.find(params[:id])
      @update_badges = false
    else
      @student = NullStudent.new
      @update_badges = false
    end
    @badges = predictor_badge_data
  end

  private

  def badge_predictor_event_attrs
    {
      prediction_type: "badge",
      course_id: current_course.id,
      user_id: current_user.id,
      student_id: current_student.try(:id),
      user_role: current_user.role(current_course),
      badge_id: params[:badge_id],
      predicted_earns: params[:times_earned],
      multiple_earns_possible: @badge.can_earn_multiple_times,
      predicted_points: badge_predicted_points,
      point_value_per_badge: @badge.point_total,
      created_at: Time.now,
      prediction_saved_successfully: @prediction_saved
    }
  end

  def badge_predicted_points
    @badge.point_total * params[:times_earned] rescue nil
  end

  def predictor_badge_data
    badges = current_course.badges.select(
      :id,
      :name,
      :description,
      :point_total,
      :visible,
      :visible_when_locked,
      :can_earn_multiple_times,
      :position,
      :updated_at,
      :icon)
    badges.each do |badge|
      prediction = badge.find_or_create_predicted_earned_badge(@student.id)
      if current_user.is_student?(current_course)
        badge.prediction = {
          id: prediction.id,
          times_earned: prediction.times_earned_including_actual
        }
      else
        badge.prediction = {
          id: prediction.id,
          times_earned: prediction.actual_times_earned
        }
      end
    end
    return badges
  end

  def find_badge
    @badge = current_course.badges.find(params[:id])
  end
end
