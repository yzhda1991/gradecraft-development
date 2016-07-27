class CoursesController < ApplicationController
  include CoursesHelper

  before_filter :ensure_staff?, except: [:index]

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

  def show
    @title = "Course Settings"
    @course = Course.find(params[:id])
  end

  def new
    @title = "Create a New Course"
    @course = Course.new
  end

  def edit
    @title = "Editing Basic Settings"
    @course = Course.find(params[:id])
  end

  def copy
    @course = Course.find(params[:id])
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
    @title = "Create a New Course"

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
    @course = Course.find(params[:id])
    @title = "Editing Basic Settings"

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
    @course = Course.find(params[:id])
    @name = @course.name
    @course.destroy

    respond_to do |format|
      format.html do
        redirect_to courses_url,
        notice: "Course #{@name} successfully deleted"
      end
    end
  end
end
