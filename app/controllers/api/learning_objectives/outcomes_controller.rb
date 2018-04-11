class API::LearningObjectives::OutcomesController < ApplicationController
  before_action :ensure_course_uses_objectives?
  before_action :ensure_staff?, except: [:outcomes_for_assignment, :outcomes_for_objective]

  # GET /api/assignments/:assignment_id/learning_objectives/outcomes
  # Optional: Provide params[:student_ids] to filter by subset
  def outcomes_for_assignment
    @cumulative_outcomes = LearningObjectiveCumulativeOutcome
      .includes(:observed_outcomes, learning_objective: :assignments)
      .where(learning_objectives: { course_id: current_course.id })
      .where(learning_objective: { assignments: { id: params[:assignment_id] } })

    filter_outcomes_by_students!

    @observed_outcomes = LearningObjectiveObservedOutcome
      .where(learning_objective_cumulative_outcomes_id: @cumulative_outcomes.pluck(:id))

    @observed_outcomes = @observed_outcomes.for_student_visible_grades if current_user_is_student?

    render "api/learning_objectives/outcomes/index", status: 200
  end

  # GET /api/learning_objectives/objectives/:objective_id/outcomes
  # Optional: Provide params[:student_ids] to filter by subset
  def outcomes_for_objective
    @cumulative_outcomes = LearningObjectiveCumulativeOutcome
      .includes(:observed_outcomes, :learning_objective)
      .where(learning_objectives: { id: params[:objective_id], course_id: current_course.id })

    filter_outcomes_by_students!

    @observed_outcomes = LearningObjectiveObservedOutcome
      .where(learning_objective_cumulative_outcomes_id: @cumulative_outcomes.pluck(:id))

    @observed_outcomes = @observed_outcomes.for_student_visible_grades if current_user_is_student?

    render "api/learning_objectives/outcomes/index", status: 200
  end

  # PUT /api/assignments/:assignment_id/students/:student_id/learning_objectives/:learning_objective_id/update_outcome
  def update_outcome
    grade = Grade.find_by assignment_id: params[:assignment_id], student_id: params[:student_id]
    cumulative_outcome = find_cumulative_outcome_for grade.student_id
    observed_outcome = find_or_initialize_outcome_for cumulative_outcome, grade

    if observed_outcome.update learning_objective_outcome_params.merge(assessed_at: grade.graded_at || DateTime.now)
      render json: { message: "Outcome saved", success: true }, status: :ok
    else
      render json: { errors: observed_outcome.errors, success: false }, status: :bad_request
    end
  end

  # PUT /api/assignments/:assignment_id/groups/:group_id/learning_objectives/:learning_objective_id/update_outcome
  def group_update_outcome
    outcomes = []
    group = Group.find params[:group_id]

    group.students.each do |student|
      grade = Grade.find_by assignment_id: params[:assignment_id], student_id: student.id
      cumulative_outcome = find_cumulative_outcome_for grade.student_id
      observed_outcome = find_or_initialize_outcome_for cumulative_outcome, grade
      outcomes << observed_outcome.update(learning_objective_outcome_params.merge(assessed_at: grade.graded_at || DateTime.now))
    end

    if outcomes.all?
      render json: { message: "Outcome saved", success: true }, status: :ok
    else
      render json: { errors: outcomes.map(&:errors).pluck(:message).flatten.uniq, success: false },
        status: :bad_request
    end
  end

  private

  def learning_objective_outcome_params
    params.require(:learning_objective_outcome).permit(:comments, :objective_level_id)
  end

  # If the current user is a student, only allow outcomes to be returned for the that person
  # Otherwise if only a subset of student_ids are provided via params, filter by that
  def filter_outcomes_by_students!
    student_ids = current_student.id if current_user_is_student?
    student_ids ||= params[:student_ids]
    @cumulative_outcomes = @cumulative_outcomes.where(user_id: student_ids) unless student_ids.blank?
  end

  def find_cumulative_outcome_for(user_id)
    objective = current_course.learning_objectives.find params[:learning_objective_id]
    objective.cumulative_outcomes.find_or_create_by user_id: user_id
  end

  def find_or_initialize_outcome_for(cumulative_outcome, grade)
    cumulative_outcome.observed_outcomes.find_or_initialize_by \
      learning_objective_assessable_type: Grade.name,
      learning_objective_assessable_id: grade.id
  end
end
