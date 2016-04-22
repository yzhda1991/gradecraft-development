class Assignments::GradesController < ApplicationController
  before_filter :ensure_staff?

  # GET /assignments/:assignment_id/grades/download
  # Sends a CSV file to the user with the current grades for all students
  # in the course for the asisgnment
  def download
    assignment = current_course.assignments.find(params[:assignment_id])
    respond_to do |format|
      format.csv {
        send_data GradeExporter.new
          .export_grades(assignment, current_course.students)
      }
    end
  end

  # GET /assignments/:assignment_id/grades/export
  # Sends a CSV file to the user with the current grades for all students
  # in the course for the asisgnment. This has more detail about the student.
  def export
    assignment = current_course.assignments.find(params[:assignment_id])
    respond_to do |format|
      format.csv do
        send_data GradeExporter.new.export_grades_with_detail assignment,
          assignment.course.students
      end
    end
  end

  # GET /assignments/:assignment_id/grades
  # View criterion grades for all students in the course for the assignment
  def index
    assignment = current_course.assignments.find(params[:assignment_id])
    redirect_to assignment_path(assignment) and return unless assignment.grade_with_rubric?

    # TODO: This should not use an AssignmentPresenter
    render :index, AssignmentPresenter.build({
      assignment: assignment,
      course: current_course,
      team_id: params[:team_id],
      view_context: view_context
      })
  end

  # GET /assignments/:assignment_id/grades/export/mass_edit
  # Quickly grading a single assignment for all students
  def mass_edit
    @assignment = current_course.assignments.find(params[:assignment_id])
    @title = "Quick Grade #{@assignment.name}"
    @assignment_type = @assignment.assignment_type
    @assignment_score_levels = @assignment.assignment_score_levels.order_by_value

    if params[:team_id].present?
      @team = current_course.teams.find_by(id: params[:team_id])
      @students = current_course.students_by_team(@team)
    else
      @students = current_course.students
    end

    @grades = Grade.find_or_create_grades(@assignment.id, @students.pluck(:id))
    @grades = @grades.sort_by { |grade| [ grade.student.last_name, grade.student.first_name ] }
  end

  # PUT /assignments/:assignment_id/grades/mass_update
  # Updates all the grades for the students in a course for an assignment
  def mass_update
    params[:assignment][:grades_attributes].each do |index, grade_params|
      grade_params.merge!(graded_at: DateTime.now)
    end if params[:assignment][:grades_attributes].present?
    @assignment = current_course.assignments.find(params[:assignment_id])
    if @assignment.update_attributes(params[:assignment])

      # @mz TODO: add specs
      enqueue_multiple_grade_update_jobs(mass_update_grade_ids)

      if !params[:team_id].blank?
        redirect_to assignment_path(@assignment, team_id: params[:team_id])
      else
        respond_with @assignment
      end
    else
      redirect_to mass_edit_assignment_grades_path(@assignment, team_id: params[:team_id]),  notice: "Oops! There was an error while saving the grades!"
    end
  end

  private

  # Schedule the `GradeUpdater` for all grades provided
  def enqueue_multiple_grade_update_jobs(grade_ids)
    grade_ids.each { |id| GradeUpdaterJob.new(grade_id: id).enqueue }
  end

  # Retrieve all grades for an assignment if it has a score
  def mass_update_grade_ids
    @assignment.grades.inject([]) do |memo, grade|
      scored_changed = grade.previous_changes[:raw_score].present?
      if scored_changed && grade.graded_or_released?
        memo << grade.id
      end
      memo
    end
  end
end
