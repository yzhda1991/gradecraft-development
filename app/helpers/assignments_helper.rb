module AssignmentsHelper
  def mark_assignment_reviewed!(assignment, user)
    if user.is_student?(assignment.course)
      if user.grade_released_for_assignment?(assignment)
        grade = user.grade_for_assignment(assignment)
        grade.feedback_reviewed! if grade && !grade.new_record?
      end
    end
  end

  def find_earned_rubric_grade(criterion, student_id)
    criterion.levels.ordered.index{|level| level.earned_for?(student_id)}
  end
end
