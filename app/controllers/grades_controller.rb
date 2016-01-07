class GradesController < ApplicationController
  respond_to :html, :json
  before_filter :set_assignment, only: [:show, :edit, :update, :destroy, :submit_rubric]
  before_filter :ensure_staff?, except: [:feedback_read, :self_log, :show, :predict_score, :async_update] # todo: probably need to add submit_rubric here
  before_filter :ensure_student?, only: [:feedback_read, :predict_score, :self_log]
  before_filter :save_referer, only: [:edit, :edit_status]

  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

  # GET /assignments/:assignment_id/grade?student_id=:id
  def show
    @assignment = current_course.assignments.find(params[:assignment_id])
    if current_user_is_student?
      redirect_to @assignment and return
    end
    # TODO: we need to add rubrics for group assignment
    if @assignment.rubric.present? && @assignment.is_individual?
      @rubric = @assignment.rubric
      @criteria = @rubric.criteria
      @criterion_grades = serialized_criterion_grades
    end

    if @assignment.has_groups?
      @group = current_course.groups.find(params[:group_id])
      @title = "#{@group.name}'s Grade for #{ @assignment.name }"
    else
      @title = "#{current_student.name}'s Grade for #{ @assignment.name }"
    end

    render :show, AssignmentPresenter.build({ assignment: @assignment, course: current_course,
                                              view_context: view_context })
  end

  # GET /assignments/:assignment_id/grade/edit?student_id=:id
  def edit
    @student = current_student

    @grade = Grade.find_or_create(@assignment,@student)
    @title = "Editing #{@student.name}'s Grade for #{@assignment.name}"

    @submission = @student.submission_for_assignment(@assignment)

    @badges = @student.earnable_course_badges_for_grade(@grade)
    @assignment_score_levels = @assignment.assignment_score_levels.order_by_value

    if @assignment.rubric.present?
      @rubric = @assignment.rubric
      @criterion_grades = serialized_criterion_grades
      # This is a patch for the Angular GradeRubricCtrl
      @return_path = URI(request.referer).path + "?student_id=#{current_student.id}"
    end

    @serialized_init_data = serialized_init_data
  end

  # To avoid duplicate grades, we don't supply a create method. Update will
  # create a new grade if none exists, and otherwise update the existing grade
  # PUT /assignments/:assignment_id/grade
  def update
    @grade = Grade.find_or_create(@assignment,current_student)

    # extract file attributes from grade params
    if params[:grade][:grade_files_attributes].present?
      @grade.add_grade_files(*(params[:grade][:grade_files_attributes]["0"]["file"]))
      params[:grade].delete :grade_files_attributes
    end

    if @grade.update_attributes params[:grade].merge(instructor_modified: true)

      # @mz TODO: ADD SPECS
      if @grade.is_released? || (@grade.is_graded? && ! @assignment.release_necessary)
        @grade_updater_job = GradeUpdaterJob.new(grade_id: @grade.id)
        @grade_updater_job.enqueue
      end

      if session[:return_to].present?
        redirect_to session[:return_to], notice: "#{@grade.student.name}'s #{@assignment.name} was successfully updated"
      else
        redirect_to assignment_path(@assignment), notice: "#{@grade.student.name}'s #{@assignment.name} was successfully updated"
      end

    else # failure
      redirect_to edit_assignment_grade_path(@assignment, :student_id => @grade.student.id), alert: "#{@grade.student.name}'s #{@assignment.name} was not successfully submitted! Please try again."
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
      render json: {message: "Earned badges successfully deleted", success: true}, status: 200
    else
      render json: {message: "Earned badges failed to delete", success: false}, status: 400
    end
  end

  # DELETE grade/:grade_id/student/:student_id/badge/:badge_id/earned_badge/:id
  def delete_earned_badge
    grade_params = params.slice(:grade_id, :student_id, :badge_id)
    if EarnedBadge.exists?(grade_params)
      EarnedBadge.where(grade_params).destroy_all
      render json: {message: "Earned badge successfully deleted", success: true}, status: 200
    else
      render json: {message: "Earned badge failed to delete", success: false}, status: 400
    end
  end

  # PUT /assignments/:assignment_id/grade/submit_rubric
  def submit_rubric
    if @submission = Submission.where(current_assignment_and_student_ids).first
      @submission.update_attributes(graded: true)
    end

    @grade = Grade.where(student_id: current_student[:id], assignment_id: @assignment[:id]).first

    if @grade
      @grade.update_attributes grade_attributes_from_rubric
    else
      @grade = Grade.create(new_grade_from_criterion_grades_attributes)
    end

    # delete existing rubric grades
    # TODO: Shouldn't require a second parameter of criterion_ids when already supplied.
    # 1. Insure criterion id is suplied in params[:criterion_grades] and required by CriterionGrade model
    # 2. params[:criterion_ids] = params[:criterion_grades].collect{|rg| rg["criterion_id"]}`
    CriterionGrade.where({ assignment_id: params[:assignment_id], student_id: params[:student_id], criterion_id: params[:criterion_ids] }).delete_all

    # create an individual record for each rubric grade
    params[:criterion_grades].collect do |criterion_grade|
      CriterionGrade.create! criterion_grade.merge(
        { submission_id: safe_submission_id,
          assignment_id: @assignment[:id],
          student_id: params[:student_id]
        }
      )
    end

    # EarnedBadges associated with a LevelBadge
    EarnedBadge.import(new_earned_level_badges, :validate => true) if params[:level_badges]

    # @mz TODO: add specs
    if @grade.is_student_visible?
      @grade_updater_job = GradeUpdaterJob.new(grade_id: @grade.id)
      @grade_updater_job.enqueue
    end

    respond_to do |format|
      format.json { render nothing: true }
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


    @grade.update_attributes(params[:grade])

    if @grade.save
      ScoreRecalculatorJob.new(user_id: @grade.student_id, course_id: current_course.id).enqueue
      redirect_to @grade.assignment, notice: "#{ @grade.student.name}'s #{@grade.assignment.name} grade was successfully deleted."
    else
      redirect_to @grade.assignment, notice:  @grade.errors.full_messages, :status => 400
    end
  end

  # DELETE /assignments/:assignment_id/grade
  def destroy
    redirect_to @assignment and return unless current_student.present?
    @grade = current_student.grade_for_assignment(@assignment)
    @grade.destroy

    redirect_to assignment_path(@assignment), notice: "#{ @grade.student.name}'s #{@assignment.name} grade was successfully deleted."
  end

  # Quickly grading a single assignment for all students
  # GET /assignments/:id/mass_grade
  def mass_edit
    @assignment = current_course.assignments.find(params[:id])
    @title = "Quick Grade #{@assignment.name}"
    @assignment_type = @assignment.assignment_type
    @assignment_score_levels = @assignment.assignment_score_levels.order_by_value

    if params[:team_id].present?
      @team = current_course.teams.find_by(id: params[:team_id])
      @students = current_course.students_by_team(@team)
    else
      @students = current_course.students
    end

    @grades = Grade.find_or_create_grades(@assignment,@students)
    @grades = @grades.sort_by { |grade| [ grade.student.last_name, grade.student.first_name ] }
  end

  # PUT /assignments/:id/mass_grade
  def mass_update
    @assignment = current_course.assignments.find(params[:id])
    if @assignment.update_attributes(params[:assignment])

      # @mz TODO: add specs
      @multiple_grade_updater_job = MultipleGradeUpdaterJob.new(grade_ids: mass_update_grade_ids)
      @multiple_grade_updater_job.enqueue

      if !params[:team_id].blank?
        redirect_to assignment_path(@assignment, :team_id => params[:team_id])
      else
        respond_with @assignment
      end
    else
      redirect_to mass_grade_assignment_path(id: @assignment.id,team_id:params[:team_id]),  notice: "Oops! There was an error while saving the grades!"
    end
  end

  # Grading an assignment for a whole group
  # GET /assignments/:id/group_grade
  def group_edit
    @assignment = current_course.assignments.find(params[:id])
    @group = @assignment.groups.find(params[:group_id])
    @title = "Grading #{@group.name}'s #{@assignment.name}"
    @assignment_score_levels = @assignment.assignment_score_levels
  end

  # PUT /assignments/:id/group_grade
  def group_update
    @assignment = current_course.assignments.find(params[:id])
    @group = @assignment.groups.find(params[:group_id])

    # TODO change to find_or_create_grades(@assignment,@group.students)
    @grades = @group.students.map do |student|
      @assignment.grades.where(:student_id => student).first || @assignment.grades.new(:student => student, :assignment => @assignment, :graded_by_id => current_user, :status => "Graded", :group_id => @group.id)
    end

    grade_ids = []
    @grades = @grades.each do |grade|
      grade.update_attributes(params[:grade])
      grade_ids << grade.id
    end

    # @mz TODO: add specs
    MultipleGradeUpdaterJob.new(grade_ids: grade_ids).enqueue

    respond_with @assignment, notice: "#{@group.name}'s #{@assignment.name} was successfully updated"
  end

  # For changing the status of a group of grades passed in grade_ids ("In Progress" => "Graded", or "Graded" => "Released")
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
    MultipleGradeUpdaterJob.new(grade_ids: grade_ids).enqueue

    if session[:return_to].present?
      redirect_to session[:return_to]
    else
      redirect_to @assignment
    end

    flash[:notice] = "Updated Grades!"
  end

  #upload grades for an assignment
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
      # @mz todo: check into what this calls is doing. is this being used?
      @students = current_course.students

      @result = GradeImporter.new(params[:file].tempfile).import(current_course, @assignment)

      # @mz TODO: add specs
      @multiple_grade_updater_job = MultipleGradeUpdaterJob.new(grade_ids: @result.successful.map(&:id))
      @multiple_grade_updater_job.enqueue

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

      @grade = Grade.find_or_create(@assignment,current_student)

      if params[:grade].present? && params[:grade][:raw_score].present?
        @grade.raw_score = params[:grade][:raw_score]
      else
        @grade.raw_score = @assignment.point_total
      end

      @grade.instructor_modified = true
      @grade.status = "Graded"


      if @grade.save
        # @mz TODO: add specs
        @grade_updater_job = GradeUpdaterJob.new(grade_id: @grade.id)
        @grade_updater_job.enqueue

        redirect_to syllabus_path, notice: 'Nice job! Thanks for logging your grade!'
      else
        redirect_to syllabus_path, notice: "We're sorry, there was an error saving your grade."
      end

    else
      redirect_to dashboard_path, notice: "This assignment is not open for self grading."
    end
  end

  # Students predicting the score they'll get on an assignent using the grade predictor
  # TODO: Change to predict_points when 'score' changes to 'points_earned and PredictedEarnedAssignment model added
  def predict_score
    @assignment = current_course.assignments.find(params[:id])
    if current_student.grade_released_for_assignment?(@assignment)
      @grade = nil
    else
      @grade = current_student.grade_for_assignment(@assignment)
      @grade.predicted_score = params[:predicted_score]
    end

    @grade_saved = @grade.nil? ? nil : @grade.save

    enqueue_predictor_event_job

    respond_to do |format|
      format.json do
        if @grade.nil?
          render :json => {errors: "You cannot predict this assignment!"}, :status => 400
        elsif @grade_saved
          render :json => {id: @assignment.id, points_earned: @grade.predicted_score}
        else
          render :json => { errors:  @grade.errors.full_messages }, :status => 400
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
                        criterion_id: rubric_criteria_with_levels.collect {|criterion| criterion[:id] } }).
                select(:id, :criterion_id, :level_id, :comments).to_json
  end

  def safe_submission_id
    @submission[:id] rescue nil
  end

  def safe_grade_possible_points
    @grade.point_total rescue nil
  end

  def new_earned_level_badges
    params[:level_badges].collect do |level_badge|
      EarnedBadge.new({
        badge_id: level_badge["badge_id"],
        submission_id: safe_submission_id,
        course_id: current_course[:id],
        student_id: current_student[:id],
        assignment_id: @assignment[:id],
        level_id: level_badge[:level_id],
        score: level_badge[:point_total],
        level_badge_id: level_badge[:id],
        student_visible: @grade.is_student_visible?
      })
    end
  end

  def enqueue_predictor_event_job
    begin
      # if Resque can reach Redis without a socket error, then enqueue the job like a normal person
      # create a predictor event in mongo to keep track of what happened
      PredictorEventJob.new(data: predictor_event_attrs).enqueue
    rescue
      # if Resque can't reach Redis because the getaddrinfo method is freaking out because of threads,
      # or because of some worker stayalive anomaly, then just use the PredictorEventJob.perform method
      # to persist the record directly to mongo with all of the logging it entails
      PredictorEventJob.perform(data: predictor_event_attrs)
    end
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

  def new_grade_from_criterion_grades_attributes
    {
      course_id: current_course[:id],
      assignment_type_id: @assignment.assignment_type_id
    }
      .merge(current_assignment_and_student_ids)
      .merge(grade_attributes_from_rubric)
  end

  def current_assignment_and_student_ids
    {
      assignment_id: @assignment[:id],
      student_id: params[:student_id]
    }
  end

  def grade_attributes_from_rubric
    {
      raw_score: params[:points_given],
      submission_id: safe_submission_id,
      # TODO: point_total should be inherited from assignment,
      # and not handled by front end logic
      point_total: params[:points_possible],
      status: params[:grade_status],
      instructor_modified: true
    }
  end

  def rubric_criteria_with_levels
    @rubric_criteria_with_levels ||= @rubric.criteria.order(:order).includes(:levels)
  end

  def set_assignment
    @assignment = Assignment.find(params[:assignment_id]) if params[:assignment_id]
  end
end
