require "active_support/inflector"
require "./lib/showtime"

class AssignmentPresenter < Showtime::Presenter
  include Showtime::ViewContext

  def assignment
    properties[:assignment]
  end

  def course
    properties[:course]
  end

  def for_team?
    properties.has_key?(:team_id) && !team.nil?
  end

  def groups
    AssignmentGroupPresenter.wrap(assignment.groups, :group, { assignment: assignment })
  end

  def group_assignment?
    assignment.has_groups?
  end

  def group_for?(user)
    user.group_for_assignment(assignment)
  end

  def has_grades?
    assignment.grades.present?
  end

  def has_reviewable_grades?
    assignment.grades.instructor_modified.present?
  end

  def has_teams?
    course.has_teams?
  end

  def individual_assignment?
    assignment.is_individual?
  end

  def new_assignment?
    !assignment.persisted?
  end

  def rubric_available?
    assignment.use_rubric? && !assignment.rubric.nil? && assignment.rubric.designed?
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
end
