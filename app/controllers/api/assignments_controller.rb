class API::AssignmentsController < ApplicationController
  before_action :ensure_staff?, only: [:show]

  # GET api/assignments
  def index
    @assignments = current_course.assignments.ordered

    if current_user_is_student?
      @student = current_student
      @allow_updates = !impersonating? && current_course.active?
      @grades = Grade.for_course(current_course).for_student(current_student)

      if !impersonating?
        @assignments.includes(:predicted_earned_grades)
        @predicted_earned_grades =
          PredictedEarnedGrade.for_course(current_course).for_student(current_student)
      end
    end
  end

  def show
    @assignment = Assignment.find(params[:id])
  end

  # optional student for graph point:
  # /api/assignments/:assignment_id/analytics
  # /api/assignments/:assignment_id/analytics?student_id=:student_id
  def analytics
    @assignment = Assignment.find(params[:assignment_id])
    @participation_rate = participation_rate
    if @assignment.pass_fail?
      @assignment_score_frequency = pass_fail_frequency
      @user_score = pass_fail_score_for params[:student_id] if params[:student_id].present?
    else
      @assignment_score_frequency = assignment_score_frequency
      @scores = @assignment.graded_or_released_scores
      @user_score = score_for params[:student_id] if params[:student_id].present?
    end
  end

  private

  # I have collected these methods from all over,
  # but they shouldn't be in a controller, either.
  # Could they go into a helper or a concern?

  # Creating an array with the set of scores earned on the assignment
  def assignment_score_frequency
    # also remove methods on Gradable Concern?
    @assignment.earned_score_count.collect { |s| { frequency: s[1], score: s[0] }}
  end

  # Creating an array with the set of pass/fail statuses earned on the assignment
  def pass_fail_frequency
    @assignment.earned_status_count.collect { |s| { frequency: s[1], score: s[0] }}}
  end

  def score_for(student_id)
    grade = Grade.where(student_id: student_id, assignment: @assignment).first
    if GradeProctor.new(grade).viewable? user: current_user, course: current_course
      return grade.raw_points
    end
    nil
  end

  def pass_fail_score_for(student_id)
    grade = Grade.where(student_id: student_id, assignment: @assignment).first
    if GradeProctor.new(grade).viewable? user: current_user, course: current_course
      grade.pass_fail_status
    end
    grade.pass_fail_status
  end

  # Tallying the percentage of participation from the entire class
  def participation_rate
    return 0 if participation_possible_count == 0
    ((@assignment.grade_count.to_f / participation_possible_count.to_f) * 100).round(2)
  end

  # denominator
  def participation_possible_count
    return current_course.graded_student_count if @assignment.is_individual?
    return @assignment.groups.count if @assignment.has_groups?
  end
end
