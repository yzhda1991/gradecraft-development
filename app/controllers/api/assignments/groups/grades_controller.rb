# rubocop:disable AndOr
class API::Assignments::Groups::GradesController < ApplicationController
  before_action :ensure_staff?

  GradeByGroup = Struct.new(:group, :grade)

  # GET /api/assignments/:assignment_id/groups/grades
  def index
    @assignment = Assignment.includes(groups: :students).find params[:assignment_id]
    render json: "Assignment is not group graded", status: :bad_request \
      and return if !@assignment.has_groups?

    @grades_by_group = @assignment.groups.map do |group|
      GradeByGroup.new(group, Gradebook.new(@assignment, group.students).grades.first)
    end
  end
end
