class API::AssignmentsController < ApplicationController
  before_filter :ensure_student?, only: [:update]

  # GET api/assignments
  def index
    @assignments = current_course.assignments.ordered

    if  current_user_is_student?
      @student = current_student
      @allow_updates = !student_impersonation?
      @grades = Grade.for_course(current_course).for_student(current_student)

      if !student_impersonation?
        @assignments.includes(:predicted_earned_grades)
        @predicted_earned_grades =
          PredictedEarnedGrade.for_course(current_course).for_student(current_student)
      end
    end
  end
end


