require "./lib/showtime"

class Assignments::GroupPresenter < Showtime::Presenter
  include Rails.application.routes.url_helpers

  def assignment
    properties[:assignment]
  end

  def student_weightable?
    assignment.assignment_type.student_weightable?
  end

  def has_levels?
    assignment.has_levels?
  end

  def pass_fail?
    assignment.pass_fail?
  end

  def grade_level(grade)
    assignment.grade_level(grade)
  end

  def grade_for_student(student)
    assignment.grades.find_by(student_id: student.id) || assignment.grades.build
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

  def students
    group.students
  end

  def path_for_new_submission
    new_assignment_submission_path assignment, submission, group_id: group.id
  end

  def path_for_grading_assignment
    grade_assignment_group_path assignment, group
  end
end
