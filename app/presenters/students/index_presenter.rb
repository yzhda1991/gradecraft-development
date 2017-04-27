require "./lib/showtime"

class Students::IndexPresenter < Showtime::Presenter
  def course
    properties[:course]
  end

  def current_user
    properties[:current_user]
  end

  def display_pseudonyms?
    course.has_in_team_leaderboards? || course.has_character_names?
  end

  def has_badges?
    course.has_badges?
  end

  def has_teams?
    course.has_teams?
  end

  def has_team_roles?
    course.has_team_roles?
  end

  def earned_badges
    @earned_badges ||=
      EarnedBadge.for_course(course)
        .where(student_id: student_ids)
        .student_visible
        .order_by_created_at
        .includes(:badge)
  end

  def flagged_users
    @flagged_users ||= FlaggedUser.for_course(course).for_flagger(current_user)
  end

  def grade_scheme_elements
    @grade_scheme_elements ||= course.grade_scheme_elements.with_lowest_points.order_by_points_asc
  end

  def student_ids
    students.map(&:id)
  end

  def students
    if @students.nil?
      query = User.joins(:course_memberships)
        .where(course_memberships: { course_id: course.id, role: :student })
      query = query.includes(course_memberships: :grade_scheme_element)
        .references(course_memberships: :grade_scheme_element)
      unless team.nil?
        query = query.includes(:team_memberships).where(team_memberships: { team_id: team_id })
      end
      query = query.order_by_high_score(course.id)

      @students = IndexStudentCollection.new(query, self)
    end

    @students
  end

  def team_id
    properties[:team_id]
  end

  def team
    @team ||= teams.find_by(id: team_id) if team_id
  end

  def teams
    course.teams
  end

  def team_memberships
    @team_memberships ||= TeamMembership.for_course(course)
      .where(student_id: student_ids)
      .includes(:team)
  end

  class IndexStudentCollection
    include Enumerable

    attr_reader :presenter

    def initialize(students, presenter)
      @students = students
      @presenter = presenter
    end

    def each
      @students.each { |student| yield IndexStudentDecorator.new(student, presenter) }
    end
  end

  class IndexStudentDecorator < SimpleDelegator
    attr_reader :presenter

    def earned_badges
      presenter.earned_badges.select { |eb| eb.student_id == self.id }
    end

    def grade_scheme
      return nil if course_membership.nil?

      course_membership.grade_scheme_element ||
        course_membership.earned_grade_scheme_element(presenter.grade_scheme_elements)
    end

    def score
      course_membership.try(:score) || 0
    end

    def last_login
      course_membership.try(:last_login_at)
    end

    def team
      presenter.team_memberships.find { |tm| tm.student_id == self.id }.try(:team)
    end

    def auditing?
      course_membership.try(:auditing)
    end

    def course_membership
      @course_membership ||= self.course_memberships.find { |cm| cm.course_id == presenter.course.id }
    end

    def initialize(student, presenter)
      @presenter = presenter
      super student
    end
  end
end
