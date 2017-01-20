class Assignments::GroupsController < ApplicationController
  before_action :ensure_staff?

  # GET /assignments/:assignment_id/groups/:id/grade
  # Grading an assignment for a group
  def grade
    @assignment = current_course.assignments.find(params[:assignment_id])
    @group = @assignment.groups.find(params[:id])
    @submission = @assignment.submissions.where(group_id: @group.id).first
    @assignment_score_levels = @assignment.assignment_score_levels.order_by_points
    @grade_next_path = path_for_next_group_grade @assignment, @group
    if @assignment.grade_with_rubric?
      @rubric = @assignment.rubric
    end
  end

  private

  def path_for_next_group_grade(assignment, group)
    next_group = assignment.next_ungraded_group(group)
    return assignment_path(assignment) unless next_group.present?
    return grade_assignment_group_path(assignment_id: assignment.id, id: next_group.id)
  end
end
