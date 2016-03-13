require "active_support/inflector"
require "./lib/showtime"
require_relative "submission_grade_history"
require_relative "../models/history_filter"

class AssignmentPresenter < Showtime::Presenter
  include Showtime::ViewContext
  include SubmissionGradeHistory

  def assignment
    properties[:assignment]
  end

  def assignment_type
    assignment.assignment_type
  end

  def comments_by_criterion_id(user)
    criterion_grades(user).inject({}) do |comments, criterion_grade|
      comments.merge criterion_grade.criterion_id => criterion_grade.comments
    end
  end

  def completion_rate
    assignment.completion_rate(course)
  end

  def course
    properties[:course]
  end

  def for_team?
    properties.key?(:team_id) && !team.nil?
  end

  def grade_for(student)
    grades.where(student_id: student.id).first || Grade.new(assignment_id: assignment.id)
  end

  def grades
    assignment.grades
  end

  def grades_available_for?(user)
    user.is_staff?(course) || (user.is_student?(course) && user.grade_released_for_assignment?(assignment))
  end

  def groups
    AssignmentGroupPresenter.wrap(assignment.groups, :group, { assignment: assignment })
  end

  def group_assignment?
    assignment.has_groups?
  end

  def group_for(student)
    student.group_for_assignment(assignment)
  end

  def group_submission_for(student)
    group_for(student).submission_for_assignment(assignment)
  end

  def has_grades?
    grades.present?
  end

  def has_reviewable_grades?
    grades.instructor_modified.present?
  end

  def has_submission_for?(user)
    assignment.accepts_submissions? && !user.submission_for_assignment(assignment).nil?
  end

  def has_teams?
    course.has_teams?
  end

  def hide_analytics?
    course.hide_analytics? && assignment.hide_analytics?
  end

  def individual_assignment?
    assignment.is_individual?
  end

  def submission_created_date_for(submissions)
    submission = submissions.first
    submission.created_at if submission
  end

  def submission_updated_date_for(submissions)
    submission = submissions.first
    submission.submitted_at if submission
  end

  def criteria
    rubric.criteria.ordered.includes(levels: :level_badges)
  end

  def new_assignment?
    !assignment.persisted?
  end

  def rubric
    assignment.fetch_or_create_rubric
  end

  def rubric_designed?
    !assignment.rubric.nil? && assignment.rubric.designed?
  end

  def criterion_grades(user_id)
    CriterionGrade
      .where(student_id: user_id)
      .where(assignment_id: assignment.id)
  end

  def rubric_max_level_count
    rubric.max_level_count
  end

  def rubric_level_earned?(user_id, level_id)
    criterion_grades(user_id).any? { |criterion_grade| criterion_grade.level_id == level_id }
  end

  def use_rubric?
    assignment.use_rubric?
  end

  def scores
    { scores: assignment.graded_or_released_scores }
  end

  def scores_for(user)
    scores = self.scores
    unless user.is_staff?(course)
      scores[:user_score] = grades.where(student_id: user.id).first.try(:raw_score)
    end
    scores
  end

  def has_scores_for?(user)
    scores = scores_for(user)
    !scores.nil? && !scores.empty? && scores.key?(:scores) && !scores[:scores].empty?
  end

  def student_logged?(user)
    assignment.student_logged? && assignment.open? && user.is_student?(course)
  end

  def students
    for_team? ? course.students_by_team(team) : course.students
  end

  def students_being_graded
    for_team? ? course.students_being_graded_by_team(team) : course.students_being_graded
  end

  def submission_date_for(student)
    submission_updated_date_for(submissions_for(student))
  end

  def submission_for_assignment(student)
    student.submission_for_assignment(assignment)
  end

  def submissions_for(student)
    student.submissions.where(assignment_id: assignment.id) || Submission.none
  end

  def submission_rate
    assignment.submission_rate(course)
  end

  def submission_grade_history(student)
    grade = self.grade_for(student)
    submission = self.submission_for_assignment(student)
    submission_grade_filtered_history(submission, grade)
  end

  def title
    title = assignment.name
  end

  def team
    @team ||= teams.find_by(id: properties[:team_id])
  end

  def teams
    course.teams
  end

  def viewable_criterion_grades(student_id=nil)
    query = assignment.criterion_grades
    query = query.where(student_id: student_id) if student_id.present?
    query
  end

  def viewable_rubric_level_earned?(student_id, level_id)
    viewable_criterion_grades(student_id).any? { |criterion_grade| criterion_grade.level_id == level_id }
  end
end
