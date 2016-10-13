class API::AssignmentsController < ApplicationController
  before_filter :ensure_student?, only: [:update]


  # GET api/assignments
  def index
    @assignments = current_course.assignments

    if current_user_is_student?
      @student = current_student
      @update_predictions = !student_impersonation?

      if !student_impersonation?
        @predicted_earned_grades =
          PredictedEarnedGrade.for_course(current_course).for_student(current_student)
        @grades =
          Grade.for_course(current_course).for_student(current_student)
      end
    end
  end
end


