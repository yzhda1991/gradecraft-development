class Assignments::GroupsController < ApplicationController
  before_action :ensure_staff?
  before_action :use_current_course

  # GET /assignments/:assignment_id/groups/:id/grade
  # Grading an assignment for a group
  def grade
    @assignment = current_course.assignments.find(params[:assignment_id])
    @group = @assignment.groups.find(params[:id])
    @submission = @assignment.submissions.where(group_id: @group.id).first
    @assignment_score_levels = @assignment.assignment_score_levels.order_by_points
    @grade_next_path = path_for_next_group_grade @assignment, @group
    @rubric = @assignment.rubric if @assignment.grade_with_rubric?
  end

  private

  def path_for_next_group_grade(assignment, group)
    # we don't supply grade next buttons when editing a released grade
    return nil if group.grade_for_assignment(assignment).graded_or_released?
    next_group = assignment.next_ungraded_group(group)
    return assignment_path(assignment) unless next_group.present?
    return grade_assignment_group_path(assignment_id: assignment.id, id: next_group.id)
  end
end
