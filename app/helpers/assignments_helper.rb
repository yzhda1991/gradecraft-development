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
    criterion.levels.ordered.to_a.index{|level| level.earned_for?(student_id)}
  end

  # Ten percent higher than threshold for highest level
  def total_available_points
    if current_course.grade_scheme_elements.empty?
      current_course.total_points
    else
      (current_course.grade_scheme_elements.order_by_highest_points[0].lowest_points * 110) / 100
    end
  end

  def percent_of_total_points(level_index)
    (current_course.grade_scheme_elements.order_by_highest_points[level_index].lowest_points).to_f / total_available_points.to_f * 100
  end

  def level_letter_grade(level_index)
    current_course.grade_scheme_elements.order_by_highest_points[level_index].letter
  end

  def level_point_threshold(level_index)
    points(current_course.grade_scheme_elements.order_by_highest_points[level_index].lowest_points)
  end
end
