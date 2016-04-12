class Assignments::GroupsController < ApplicationController
  before_filter :ensure_staff?

  # Grading an assignment for a whole group
  def grade
    @assignment = current_course.assignments.find(params[:assignment_id])
    @group = @assignment.groups.find(params[:id])
    @submission_id = @assignment.submissions.where(group_id: @group.id).first.try(:id)
    @title = "Grading #{ @group.name }'s #{@assignment.name}"
    @assignment_score_levels = @assignment.assignment_score_levels

    if @assignment.grade_with_rubric?
      @rubric = @assignment.rubric
      # This is sent to the Angular controlled submit button
      @return_path = URI(request.referer).path
    end
  end
end
