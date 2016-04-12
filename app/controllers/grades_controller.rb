class GradesController < ApplicationController
  respond_to :html, :json
  before_filter :set_assignment,
    only: [:show, :edit, :update, :destroy, :submit_rubric]
  before_filter :ensure_staff?,
    except: [:feedback_read, :self_log, :show, :predict_score, :async_update]
  # TODO: probably need to add submit_rubric here
  before_filter :ensure_student?,
    only: [:feedback_read, :predict_score, :self_log]
  before_filter :save_referer, only: [:edit, :edit_status]

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == "application/json" }

  # GET /assignments/:assignment_id/grade?student_id=:id
  def show
    if current_user_is_student?
      redirect_to @assignment and return
    end

    if @assignment.grade_with_rubric?
      @rubric = @assignment.rubric
      @criteria = @rubric.criteria
      @criterion_grades = serialized_criterion_grades
    end

    if @assignment.has_groups?
      group = current_student.group_for_assignment(@assignment)
      @title = "#{group.name}'s Grade for #{ @assignment.name }"
    else
      @title = "#{current_student.name}'s Grade for #{ @assignment.name }"
    end

    render :show, AssignmentPresenter.build({ assignment: @assignment,
                                              course: current_course,
                                              view_context: view_context })
  end

  # GET /assignments/:assignment_id/grade/edit?student_id=:id
  def edit
    @student = current_student

    @grade = Grade.find_or_create(@assignment.id, @student.id)
    @title = "Editing #{@student.name}'s Grade for #{@assignment.name}"

    @submission = @student.submission_for_assignment(@assignment)

    @badges = @student.earnable_course_badges_for_grade(@grade)
    @assignment_score_levels =
      @assignment.assignment_score_levels.order_by_value

    if @assignment.grade_with_rubric?
      @rubric = @assignment.rubric
      @criterion_grades = serialized_criterion_grades
      # This is sent to the Angular controlled submit button
      @return_path =
        URI(request.referer).path + "?student_id=#{current_student.id}"
    end

    @serialized_init_data = serialized_init_data
  end

  # To avoid duplicate grades, we don't supply a create method. Update will
  # create a new grade if none exists, and otherwise update the existing grade
  # PUT /assignments/:assignment_id/grade
  def update
    @grade = Grade.find_or_create(@assignment.id, current_student.id)

    if @grade.update_attributes params[:grade].merge(graded_at: DateTime.now,
        instructor_modified: true)

      if GradeProctor.new(@grade).viewable?
        grade_updater_job = GradeUpdaterJob.new(grade_id: @grade.id)
        grade_updater_job.enqueue
      end

      if session[:return_to].present?
        redirect_to session[:return_to], notice: "#{@grade.student.name}'s #{@assignment.name} was successfully updated"
      else
        redirect_to assignment_path(@assignment), notice: "#{@grade.student.name}'s #{@assignment.name} was successfully updated"
      end

    else # failure
      redirect_to edit_assignment_grade_path(@assignment, student_id: @grade.student.id), alert: "#{@grade.student.name}'s #{@assignment.name} was not successfully submitted! Please try again."
    end
  end

  # PUT /grades/:id/async_update
  def async_update
    Grade.find(params[:id]).update_attributes(
      {
         feedback: params[:feedback],
         instructor_modified: true,
         status: params[:status],
         updated_at: Time.now,
         graded_at: DateTime.now,
         raw_score: params[:raw_score]
      }
    )
    render nothing: true
  end

  # POST /grades/earn_student_badge
  def earn_student_badge
    @earned_badge = EarnedBadge.create params[:earned_badge]
    logger.info @earned_badge.errors.full_messages
    render json: @earned_badge
  end

  # POST /grades/earn_student_badges
  def earn_student_badges
    @earned_badges = EarnedBadge.create params[:earned_badges]
    render json: @earned_badges
  end

  # DELETE grade/:grade_id/earned_badges
  def delete_all_earned_badges
    if EarnedBadge.exists?(grade_id: params[:grade_id])
      EarnedBadge.where(grade_id: params[:grade_id]).destroy_all
      render json: {
        message: "Earned badges successfully deleted",
        success: true
        },
        status: 200
    else
      render json: {
        message: "Earned badges failed to delete",
        success: false
        },
        status: 400
    end
  end

  # DELETE grade/:grade_id/student/:student_id/badge/:badge_id/earned_badge/:id
  def delete_earned_badge
    grade_params = params.slice(:grade_id, :student_id, :badge_id)
    if EarnedBadge.exists?(grade_params)
      EarnedBadge.where(grade_params).destroy_all
      render json: { message: "Earned badge successfully deleted", success: true }, status: 200
    else
      render json: { message: "Earned badge failed to delete", success: false }, status: 400
    end
  end

  # This is the method used when faculty delete a grade
  # it preserves the predicted grade
  # POST /assignments/:id/grades/remove
  def remove
    @grade = Grade.find(params[:id])
    @grade.raw_score = nil
    @grade.status = nil
    @grade.feedback = nil
    @grade.feedback_read = false
    @grade.feedback_read_at = nil
    @grade.feedback_reviewed = false
    @grade.feedback_reviewed_at = nil
    @grade.instructor_modified = false
    @grade.graded_at = nil

    @grade.update_attributes(params[:grade])

    if @grade.save
      score_recalculator(@grade.student)
      redirect_to @grade.assignment,
        notice: "#{ @grade.student.name }'s #{ @grade.assignment.name } grade was successfully deleted."
    else
      redirect_to @grade.assignment, notice:  @grade.errors.full_messages, status: 400
    end
  end

  # POST /assignments/:id/grades/exclude
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

  # POST /assignments/:id/grades/include
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

  # DELETE /assignments/:assignment_id/grade
  def destroy
    redirect_to @assignment and return unless current_student.present?
    @grade = current_student.grade_for_assignment(@assignment)
    @grade.destroy
    score_recalculator(@grade.student)

    redirect_to assignment_path(@assignment), notice: "#{ @grade.student.name }'s
      #{ @assignment.name } grade was successfully deleted."
  end

  # PUT /assignments/:id/mass_grade
  def mass_update
    params[:assignment][:grades_attributes].each do |index, grade_params|
      grade_params.merge!(graded_at: DateTime.now)
    end if params[:assignment][:grades_attributes].present?
    @assignment = current_course.assignments.find(params[:id])
    if @assignment.update_attributes(params[:assignment])

      # @mz TODO: add specs
      enqueue_multiple_grade_update_jobs(mass_update_grade_ids)

      if !params[:team_id].blank?
        redirect_to assignment_path(@assignment, team_id: params[:team_id])
      else
        respond_with @assignment
      end
    else
      redirect_to mass_grade_assignment_path(id: @assignment.id, team_id: params[:team_id]),  notice: "Oops! There was an error while saving the grades!"
    end
  end

  # Grading an assignment for a whole group
  # GET /assignments/:id/group_grade
  def group_edit
    @assignment = current_course.assignments.find(params[:id])
    @group = @assignment.groups.find(params[:group_id])
    @submission_id = @assignment.submissions.where(group_id: @group.id).first.try(:id)
    @title = "Grading #{ @group.name }'s #{@assignment.name}"
    @assignment_score_levels = @assignment.assignment_score_levels

    if @assignment.grade_with_rubric?
      @rubric = @assignment.rubric
      # This is sent to the Angular controlled submit button
      @return_path = URI(request.referer).path + "?group_id=#{ @group.id }"
    end
  end

  # PUT /assignments/:id/group_grade
  def group_update
    @assignment = current_course.assignments.find(params[:id])
    @group = @assignment.groups.find(params[:group_id])

    @grades = Grade.find_or_create_grades(@assignment.id, @group.students.pluck(:id))

    grade_ids = []
    @grades = @grades.each do |grade|
      grade.update_attributes(params[:grade].merge(graded_at: DateTime.now,
        group_type: "Group", group_id: @group.id))
      grade_ids << grade.id
    end

    # @mz TODO: add specs
    enqueue_multiple_grade_update_jobs(grade_ids)

    respond_with @assignment, notice: "#{@group.name}'s #{@assignment.name} was successfully updated"
  end

  # For changing the status of a group of grades passed in grade_ids
  #  ("In Progress" => "Graded", or "Graded" => "Released")
  # GET  /assignments/:id/grades/edit_status
  def edit_status
    @assignment = current_course.assignments.find(params[:id])
    @title = "#{@assignment.name} Grade Statuses"
    @grades = @assignment.grades.find(params[:grade_ids])
  end

  # PUT /assignments/:id/grades/update_status
  def update_status
    @assignment = current_course.assignments.find(params[:id])
    @grades = @assignment.grades.find(params[:grade_ids])
    status = params[:grade][:status]

    grade_ids = []
    @grades = @grades.each do |grade|
      grade.update(status: status)
      grade_ids << grade.id
    end

    # @mz TODO: add specs
    enqueue_multiple_grade_update_jobs(grade_ids)

    if session[:return_to].present?
      redirect_to session[:return_to]
    else
      redirect_to @assignment
    end

    flash[:notice] = "Updated Grades!"
  end

  # upload grades for an assignment
  def import
    @assignment = current_course.assignments.find(params[:id])
    @title = "Import Grades for #{@assignment.name}"
  end

  def upload
    @assignment = current_course.assignments.find(params[:id])

    if params[:file].blank?
      flash[:notice] = "File missing"
      redirect_to assignment_path(@assignment)
    else
      # @mz TODO: check into what this calls is doing. is this being used?
      @students = current_course.students

      @result = GradeImporter.new(params[:file].tempfile).import(current_course, @assignment)

      # @mz TODO: add specs
      grade_ids = @result.successful.map(&:id)

      enqueue_multiple_grade_update_jobs(grade_ids)

      render :import_results
    end
  end

  def feedback_read
    @assignment = current_course.assignments.find params[:id]
    @grade = @assignment.grades.find params[:grade_id]
    @grade.feedback_read!
    redirect_to assignment_path(@assignment), notice: "Thank you for letting us know!"
  end

  # Allows students to log grades for student logged assignments
  # either sets raw score to params[:grade][:raw_score]
  # or defaults to point total for assignment
  def self_log
    @assignment = current_course.assignments.find(params[:id])
    if @assignment.open? && @assignment.student_logged?

      @grade = Grade.find_or_create(@assignment.id, current_student.id)

      if params[:grade].present? && params[:grade][:raw_score].present?
        @grade.raw_score = params[:grade][:raw_score]
      else
        @grade.raw_score = @assignment.point_total
      end

      @grade.instructor_modified = true
      @grade.status = "Graded"

      if @grade.save
        # @mz TODO: add specs
        grade_updater_job = GradeUpdaterJob.new(grade_id: @grade.id)
        grade_updater_job.enqueue

        redirect_to syllabus_path, notice: 'Nice job! Thanks for logging your grade!'
      else
        redirect_to syllabus_path, notice: "We're sorry, there was an error saving your grade."
      end

    else
      redirect_to dashboard_path, notice: "This assignment is not open for self grading."
    end
  end

  # Students predicting the score they'll get on an assignment using the grade
  # predictor
  # TODO: Change to predict_points when 'score' changes to 'points_earned and
  # PredictedEarnedAssignment model added
  def predict_score
    @assignment = current_course.assignments.find(params[:id])
    if current_student.grade_released_for_assignment?(@assignment)
      @grade = nil
    else
      @grade = current_student.grade_for_assignment(@assignment)
      @grade.predicted_score = params[:predicted_score]
    end

    @grade_saved = @grade.nil? ? nil : @grade.save

    # TODO: this should be implemented with a PredictorEventLogger instead of a
    # PredictorEventJob since the PredictorEventLogger has logic for cleaning up
    # request params data, but for now this is better than what we had
    #
    PredictorEventJob.new(data: predictor_event_attrs).enqueue_with_fallback

    respond_to do |format|
      format.json do
        if @grade.nil?
          render json: {errors: "You cannot predict this assignment!"}, status: 400
        elsif @grade_saved
          render json: {id: @assignment.id, points_earned: @grade.predicted_score}
        else
          render json: { errors:  @grade.errors.full_messages }, status: 400
        end
      end
    end
  end

  private

  def temp_view_context
    @temp_view_context ||= ApplicationController.new.view_context
  end

  def serialized_init_data
    JbuilderTemplate.new(temp_view_context).encode do |json|
      json.grade do
        json.partial! "grades/grade", grade: @grade, assignment: @assignment
      end

      json.badges do
        json.partial! "grades/badges", badges: @badges, student_id: @student[:id]
      end

      json.assignment do
        json.partial! "grades/assignment", assignment: @assignment
      end

      json.assignment_score_levels do
        json.partial! "grades/assignment_score_levels", assignment_score_levels: @assignment_score_levels
      end
    end.to_json
  end

  def serialized_criterion_grades
    CriterionGrade.where({ student_id: params[:student_id],
                        assignment_id: params[:assignment_id],
                        criterion_id: rubric_criteria_with_levels.collect {|criterion| criterion[:id] } })
                        .select(:id, :criterion_id, :level_id, :comments).to_json
  end

  def safe_grade_possible_points
    @grade.point_total rescue nil
  end

  def predictor_event_attrs
    {
      prediction_type: "grade",
      course_id: current_course.id,
      user_id: current_user.id,
      student_id: current_student.try(:id),
      user_role: current_user.role(current_course),
      assignment_id: params[:id],
      predicted_points: params[:predicted_score],
      possible_points: safe_grade_possible_points,
      created_at: Time.now,
      prediction_saved_successfully: @grade_saved
    }
  end

  def mass_update_grade_ids
    @assignment.grades.inject([]) do |memo, grade|
      scored_changed = grade.previous_changes[:raw_score].present?
      if scored_changed && grade.graded_or_released?
        memo << grade.id
      end
      memo
    end
  end

  def score_recalculator(student)
    ScoreRecalculatorJob.new(user_id: student.id,
                           course_id: current_course.id).enqueue
  end

  def enqueue_multiple_grade_update_jobs(grade_ids)
    grade_ids.each do |grade_id|
      grade_updater_job = GradeUpdaterJob.new(grade_id: grade_id)
      grade_updater_job.enqueue
    end
  end

  def rubric_criteria_with_levels
    @rubric_criteria_with_levels ||= @rubric.criteria.ordered.includes(:levels)
  end

  def set_assignment
    @assignment = Assignment.find(params[:assignment_id]) if params[:assignment_id]
  end
end
