require "active_support/inflector"
require "./lib/showtime"

class AssignmentPresenter < Showtime::Presenter
  include Showtime::ViewContext

  def assignment
    properties[:assignment]
  end

  def assignment_type
    assignment.assignment_type
  end

  def comments_by_metric_id(user)
    rubric_grades(user).inject({}) do |comments, rubric_grade|
      comments.merge rubric_grade.metric_id => rubric_grade.comments
    end
  end

  def completion_rate
    assignment.completion_rate(course)
  end

  def course
    properties[:course]
  end

  def for_team?
    properties.has_key?(:team_id) && !team.nil?
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

  def group_submission_updated?(student)
    submission = group_submission_for(student)
    submission.updated_at != submission.created_at
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
    if submission
      submission.updated_at if submission.updated_at != submission.created_at
    end
  end

  def metrics
    rubric.metrics.ordered.includes(:tiers => :tier_badges)
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

  def rubric_grades(user_id)
    RubricGrade.
      joins("left outer join submissions on submissions.id = rubric_grades.submission_id").
      where(student_id: user_id).
      where(assignment_id: assignment.id)
  end

  def rubric_max_tier_count
    rubric.max_tier_count
  end

  def rubric_tier_earned?(user_id, tier_id)
    rubric_grades(user_id).any? { |rubric_grade| rubric_grade.tier_id == tier_id }
  end

  def use_rubric?
    assignment.use_rubric?
  end

  def scores
    { scores: assignment.graded_or_released_scores }
  end

  def scores_for(user)
    return scores if user.is_staff?(course)
    assignment.grades_for_assignment(user)
  end

  def has_scores_for?(user)
    scores = scores_for(user)
    !scores.nil? && !scores.empty? && scores.has_key?(:scores) && !scores[:scores].empty?
  end

  def student_logged?(user)
    assignment.student_logged? && assignment.open? && user.is_student?(course)
  end

  def students
    for_team? ? course.students_by_team(team) : course.students
  end

  def submission_date_for(student)
    submission = submissions_for(student).first
    submission.updated_at if submission
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

  def submission_updated?(student)
    submission = submission_for_assignment(student)
    submission.updated_at != submission.created_at
  end

  def title
    title = assignment.name
    if assignment.pass_fail?
      title += " (#{view_context.term_for :pass}/#{view_context.term_for :fail})"
    else
      title += " (#{view_context.number_with_delimiter assignment.point_total} #{"points".pluralize(assignment.point_total)})"
    end
    title
  end

  def team
    @team ||= teams.find_by(id: properties[:team_id])
  end

  def teams
    course.teams
  end

  def viewable_rubric_grades(student_id)
    assignment.rubric_grades.where(student_id: student_id)
  end

  def viewable_rubric_tier_earned?(student_id, tier_id)
    viewable_rubric_grades(student_id).any? { |rubric_grade| rubric_grade.tier_id == tier_id }
  end
end
