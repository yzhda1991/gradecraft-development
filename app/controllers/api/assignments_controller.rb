class API::AssignmentsController < ApplicationController
  before_action :ensure_staff?, only: [:show]

  # GET api/assignments
  def index
    @assignments = current_course.assignments.ordered

    if  current_user_is_student?
      @student = current_student
      @allow_updates = !impersonating?
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
end
