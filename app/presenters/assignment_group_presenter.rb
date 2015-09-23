require "./lib/showtime"

class AssignmentGroupPresenter < Showtime::Presenter
  def assignment
    properties[:assignment]
  end

  def assignment_graded?
    !group.students.first.grade_for_assignment(assignment).raw_score.nil?
  end

  def can_grade?
    assignment.release_necessary? && assignment.grades.present?
  end

  def grade_for(student)
    assignment.grades.find_by(student_id: student.id)
  end

  def group
    properties[:group]
  end

  def has_submission?
    !submission.nil?
  end

  def submission
    @submission ||= group.submission_for_assignment(assignment)
  end

  def title
    "#{group.name} Grades"
  end
end
