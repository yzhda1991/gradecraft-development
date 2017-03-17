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

  # /api/assignments/:assignment_id/analytics
  # Needs to replace:
  #  app/views/grades/analytics/_group_analytics.haml
  #  app/views/grades/analytics/_individual_analytics.haml
  #  methods on Assignments::Presenter
  #  methods on Gradable Concern
  #  methods on Assignment
  def analytics
    @assignment = Assignment.find(params[:assignment_id])
    # data as presented in the analytics partials
    if @assignment.pass_fail?
      @data_levels = @assignment.percentage_pass_fail_earned
      @data_scores = pass_fail_scores_for(current_user)
    else
      @data_levels = @assignment.percentage_score_earned
      @data_scores = scores_for(current_user)
    end
  end

  private

  def scores_for(user)
    scores = { scores: @assignment.graded_or_released_scores }
    grade = Grade.where(student_id: user.id).first if user.present?
    if GradeProctor.new(grade).viewable? user: user, course: current_course
      scores[:user_score] = grade.raw_points
    end
    scores
  end

  # this is insanity!
  def pass_fail_scores_for(user)
    scores = { scores: @assignment.grades.graded_or_released }
    grade = Grade.where(student_id: user.id).first if user.present?
    if GradeProctor.new(grade).viewable? user: user, course: current_course
      scores[:user_score] = grade.pass_fail_status
    end
    scores
  end
end
