class API::LearningObjectives::ObjectivesController < ApplicationController
  before_action :ensure_staff?, except: [:index, :show]
  before_action :find_objective, only: [:show, :update, :destroy]

  # GET /api/learning_objectives/objectives
  def index
    if params[:assignment_id]
      assignment = Assignment.find params[:assignment_id]
      @objectives = assignment.learning_objectives.ordered_by_name
    else
      @objectives = current_course.learning_objectives.ordered_by_name
    end
  end

  # GET /api/learning_objectives/objectives/:id
  def show
    @include_outcomes = params[:include_outcomes]
    render "api/learning_objectives/objectives/show", status: 201
  end

  # POST /api/learning_objectives/objectives
  def create
    @objective = current_course.learning_objectives.new learning_objective_params

    if @objective.save
      render "api/learning_objectives/objectives/show", status: 201
    else
      render json: {
        message: "Failed to create learning objective",
        errors: @objective.errors.messages,
        success: false
      }, status: 400
    end
  end

  # PUT /api/learning_objectives/objectives/:id
  def update
    params = learning_objective_params[:learning_objective_links_attributes].present? ? learning_objective_params_with_links : learning_objective_params

    begin
      @objective.learning_objective_links.destroy_all # not the most performant method but easiest for now
      @objective.update params
      render "api/learning_objectives/objectives/show", status: 200
    rescue ActiveRecord::RecordInvalid, ActiveRecord::RecordNotSaved
      render json: {
        message: "Failed to update learning objective",
        errors: @objective.errors.messages,
        success: false
      }, status: 400
    end
  end

  # DELETE /api/learning_objectives/objectives/:id
  def destroy
    @objective.destroy

    if @objective.destroyed?
      render json: { message: "Deleted #{@objective.name}", success: true },
        status: 200
    else
      render json: { message: "Failed to delete #{@objective.name}", success: false },
        status: 500
    end
  end

  private

  def learning_objective_params
    params.require(:learning_objective).permit :id, :name, :description,
      :count_to_achieve, :category_id, :points_to_completion, learning_objective_links_attributes: []
  end

  def learning_objective_params_with_links
    learning_objective_params.merge(learning_objective_links_attributes: learning_objective_params[:learning_objective_links_attributes].map { |assignment_id|
      {
        learning_objective_linkable_type: "Assignment",
        learning_objective_linkable_id: assignment_id,
        course_id: current_course.id
      }
    })
  end

  def find_objective
    @objective = current_course.learning_objectives.find params[:id]
  end
end
