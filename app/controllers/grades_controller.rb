class GradesController < ApplicationController
  respond_to :html, :json

  before_action :ensure_staff?,
    except: [:feedback_read, :show, :async_update]
  before_action :ensure_student?, only: :feedback_read
  before_action :use_current_course, only: [:show, :edit]

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == "application/json" }

  # GET /grades/:id
  def show
    @grade = Grade.find params[:id]
    # rubocop:disable AndOr
    redirect_to @grade.assignment and return unless current_user_is_staff?

    name = @grade.group.nil? ? @grade.student.name : @grade.group.name

    render :show, Assignments::Presenter.build({
      assignment: @grade.assignment,
      course: current_course,
      view_context: view_context
      })
  end

  # GET /grades/:id/edit
  def edit
    @grade = Grade.find params[:id]
    @grade.update(complete: false, student_visible: false) if
      @grade.complete? || @grade.student_visible?
    @submission = @grade.student.submission_for_assignment(@grade.assignment)
    @team = Team.find(params[:team_id]) if params[:team_id]
    if request.referer && request.referer.match(grading_status_path)
      @submit_path = request.referer
    elsif @team.present?
      @submit_path =  assignment_path(@grade.assignment, team_id: @team.id)
    else
      @submit_path = assignment_path(@grade.assignment)
    end
    @grade_next_path = path_for_next_grade @grade, @team
  end

  # POST /grades/:id/exclude
  def exclude
    grade = Grade.find(params[:id])
    grade.excluded_from_course_score = true
    grade.excluded_by_id = current_user.id
    grade.excluded_at = Time.now
    if grade.save
      score_recalculator(grade.student)
      redirect_to student_path(grade.student), notice: "#{ grade.student.name }'s
      #{ grade.assignment.name } grade was successfully excluded from their
      total score."
    else
      redirect_to student_path(grade.student), alert: "#{ grade.student.name }'s
      #{ grade.assignment.name } grade was not successfully excluded from their
      total score - please try again."
    end
  end

  # POST /grades/:id/include
  def include
    grade = Grade.find(params[:id])
    grade.excluded_from_course_score = false
    grade.excluded_by_id = nil
    grade.excluded_at = nil
    if grade.save
      score_recalculator(grade.student)
      redirect_to student_path(grade.student), notice: "#{ grade.student.name }'s
      #{ grade.assignment.name } grade was successfully re-added to their total
      score."
    else
      redirect_to student_path(grade.student), alert: "#{ grade.student.name }'s
      #{ grade.assignment.name } grade was not successfully re-added to their
      total score - please try again."
    end
  end

  # DELETE /grades/:id
  def destroy
    grade = Grade.find(params[:id])
    authorize! :destroy, grade
    grade.destroy
    score_recalculator(grade.student)

    redirect_to assignment_path(grade.assignment),
      notice: "#{grade.student.name}'s #{grade.assignment.name} grade was "\
              "successfully deleted."
  rescue CanCan::AccessDenied
    # This is handled here so that a different redirect path can be specified
    redirect_to assignment_path(grade.assignment)
  end

  # POST /grades/:id/feedback_read
  def feedback_read
    grade = Grade.find params[:id]
    authorize! :update, grade, student_logged: false
    grade.feedback_read!
    redirect_to assignment_path(grade.assignment),
      notice: "Thank you for letting us know!"
  end

  # PUT /grades/release
  # Releases grades for assignment in grade_ids params
  def release
    grades = Grade.find(params[:grade_ids])

    grade_ids = grades.collect do |grade|
      grade.instructor_modified = true
      grade.complete = true
      grade.student_visible = true
      grade.save
      grade.id
    end

    grade_ids.each { |id| GradeUpdaterJob.new(grade_id: id).enqueue }

    redirect_to grading_status_path, notice: "Grades were successfully released!"
  end

  private

  def grade_params
    params.require(:grade).permit :_destroy, :score, :adjustment_points, :adjustment_points_feedback,
      :assignment_id, :assignment_type_id, :assignments_attributes, :course_id,
      :earned_badges_attributes, :excluded_by_id, :excluded_at, :excluded_from_course_score,
      :feedback, :feedback_read, :feedback_read_at, :feedback_reviewed, :feedback_reviewed_at,
      :final_points, :graded_at, :graded_by_id,
      :group_id, :instructor_modified, :pass_fail_status,
      :full_points, :raw_points, :student_id, :submission_id, :team_id, :status
  end

  def temp_view_context
    @temp_view_context ||= ApplicationController.new.view_context
  end

  def score_recalculator(student)
    ScoreRecalculatorJob.new(user_id: student.id,
                           course_id: current_course.id).enqueue
  end

  def path_for_next_grade(grade, team=nil)
    # we don't supply a next grade when editing existing grades
    return nil if grade.student_visible?
    next_student = grade.assignment.next_ungraded_student(grade.student, team)
    team_params = team ? {team_id: team.id} : nil
    return assignment_path(grade.assignment, team_params) unless next_student.present?
    return edit_grade_path(
      Grade.find_or_create(grade.assignment.id, next_student.id), team_params
    )
  end
end
