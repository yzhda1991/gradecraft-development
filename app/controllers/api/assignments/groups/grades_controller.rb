class API::Assignments::Groups::GradesController < ApplicationController
  before_action :ensure_staff?
  before_action :ensure_group_graded!

  GradeByGroup = Struct.new(:group, :grade)

  # GET /api/assignments/:assignment_id/groups/grades
  def index
    @groups = @assignment.groups.order_by_name

    @group_grades = {}
    @groups.each { |group| @group_grades[group.id] = Gradebook.new(@assignment, group.students.order_by_name).grades }
  end

  # GET /api/assignments/:assignment_id/groups/grades/mass_edit
  #
  # Returns a very specific structure that the associated update method on the
  # controller expects
  def mass_edit
    @grades_by_group = @assignment.groups.order_by_name.map do |group|
      GradeByGroup.new(group, Gradebook.new(@assignment, group.students).grades.first)
    end
  end

  private

  def ensure_group_graded!
    @assignment = current_course.assignments.includes(:groups, :grades).find params[:assignment_id]

    render json: "Assignment is not group graded", status: :bad_request \
      if !@assignment.has_groups?
  end
end
