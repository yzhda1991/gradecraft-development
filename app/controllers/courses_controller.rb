class CoursesController < ApplicationController
  include CoursesHelper

  skip_before_filter :require_login, only: [:badges]
  before_filter :ensure_staff?, except: [:index, :badges]
  before_action :find_course, only: [:show, :edit, :multiplier_settings,
    :custom_terms, :course_details, :player_settings, :student_onboarding_setup,
  :copy, :update, :destroy, :badges]

  # rubocop:disable AndOr
  def index
    @title = "My Courses"
    @courses = current_user.courses
    # Used to return the course list to search
    respond_to do |format|
      format.html
      format.json do
        render json: @courses.to_json(only: [:id, :name, :course_number, :year, :semester])
      end
    end
  end

  def course_creation_wizard

  end

  def show
    @title = "Course Settings"
  end

  def new
    @title = "Create a New Course"
    @course = Course.new
  end

  def edit
    @title = "Editing Basic Settings"
  end

  def multiplier_settings
    @title = "Multiplier Settings"
  end

  def custom_terms
    @title = "Custom Terms"
  end

  def course_details
    @title = "Course Details"
  end

  def player_settings
    @title = "#{term_for :student} Settings"
  end

  def student_onboarding_setup
    @title = "Student Onboarding Setup"
  end

  def badges
    if @course.has_public_badges?
      @title = @course.name
      @badges = @course.badges
    else
      redirect_to root_path, alert: "Whoops, nothing to see here! That data is not available."
    end
  end

  def copy
    duplicated = @course.copy(params[:copy_type], {})
    if duplicated.save
      if !current_user_is_admin? && current_user.role(duplicated).nil?
        duplicated.course_memberships.create(user: current_user, role: current_role)
      end
      duplicated.recalculate_student_scores unless duplicated.student_count.zero?
      session[:course_id] = duplicated.id
      redirect_to edit_course_path(duplicated.id),
        notice: "#{@course.name} successfully copied" and return
    else
      redirect_to courses_path,
        alert: "#{@course.name} was not successfully copied" and return
    end
  end

  def create
    @course = Course.new(course_params)

    respond_to do |format|
      if @course.save
        if !current_user_is_admin?
          @course.course_memberships.create(user_id: current_user.id,
                                            role: current_user.role(current_course))
        end
        session[:course_id] = @course.id
        bust_course_list_cache current_user
        format.html do
          redirect_to course_path(@course),
          notice: "Course #{@course.name} successfully created"
        end
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    respond_to do |format|
      if @course.update_attributes(course_params)
        bust_course_list_cache current_user
        format.html do
          redirect_to @course,
          notice: "Course #{@course.name} successfully updated"
        end
      else
        format.html { render action: "edit" }
      end
    end
  end

  def destroy
    @name = @course.name
    @course.destroy

    respond_to do |format|
      format.html do
        redirect_to courses_url,
        notice: "Course #{@name} successfully deleted"
      end
    end
  end

  private

  def course_params
    params.require(:course).permit :course_number, :name,
      :semester, :year, :has_badges, :has_teams, :instructors_of_record_ids,
      :team_term, :student_term, :section_leader_term, :group_term, :lti_uid,
      :user_id, :course_id, :course_rules, :syllabus,
      :has_character_names, :has_team_roles, :has_character_profiles, :hide_analytics,
      :total_weights, :weights_close_at, :has_public_badges,
      :assignment_weight_type, :has_submissions, :teams_visible,
      :weight_term, :fail_term, :pass_term,
      :max_weights_per_assignment_type, :assignments,
      :accepts_submissions, :tagline, :office, :phone,
      :class_email, :twitter_handle, :twitter_hashtag, :location, :office_hours,
      :meeting_times, :assignment_term, :challenge_term, :badge_term, :gameful_philosophy,
      :team_score_average, :has_team_challenges, :team_leader_term,
      :max_assignment_types_weighted, :full_points, :has_in_team_leaderboards,
      :grade_scheme_elements_attributes, :add_team_score_to_student, :status,
      :assignments_attributes, :start_date, :end_date,
      unlock_conditions_attributes: [:unlockable_id, :unlockable_type, :condition_id,
        :condition_type, :condition_state, :condition_value, :condition_date]
  end

  def find_course
    @course = Course.find(params[:id])
  end
end
