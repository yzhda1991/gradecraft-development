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
    @course = Course.new(params[:course])

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
      if @course.update_attributes(params[:course])
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

  def find_course
    @course = Course.find(params[:id])
  end
end
