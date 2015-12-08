class PredictedAssignmentCollection
  include Enumerable

  attr_reader :assignments, :user

  def initialize(assignments, user)
    @assignments = pluck_attributes assignments
    @user = user
  end

  def each
    assignments.each { |assignment| yield PredictedAssignment.new(assignment, user) }
  end

  private

  def pluck_attributes(assignments)
    assignments.select(
      :accepts_resubmissions_until,
      :accepts_submissions,
      :accepts_submissions_until,
      :assignment_type_id,
      :course_id,
      :description,
      :due_at,
      :grade_scope,
      :id,
      :include_in_predictor,
      :name,
      :open_at,
      :pass_fail,
      :point_total,
      :points_predictor_display,
      :position,
      :release_necessary,
      :required,
      :resubmissions_allowed,
      :student_logged,
      :thumbnail,
      :use_rubric,
      :visible,
      :visible_when_locked
    )
  end
end
