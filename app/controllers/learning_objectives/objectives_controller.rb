class LearningObjectives::ObjectivesController < ApplicationController
  before_action :ensure_staff?, except: :show
  before_action :ensure_course_uses_objectives?
  before_action :use_current_course

  # GET /learning_objectives/objectives
  def index
  end

  # GET /learning_objectives/objectives/:id
  def show
    @objective = @course.learning_objectives.find params[:id]
    @student_id = current_student.try(:id)
  end

  # GET /learning_objectives/objectives/new
  def new
    @category = @course.learning_objective_categories.find(params[:category_id]) \
      unless params[:category_id].nil?
  end

  # GET /learning_objectives/objectives/:id/edit
  def edit
    @objective = @course.learning_objectives.find params[:id]
  end
end
