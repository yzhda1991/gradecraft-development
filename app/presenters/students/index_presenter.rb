require "./lib/showtime"

class Students::IndexPresenter < Showtime::Presenter
  def course
    properties[:course]
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
        .order_by_created_at
        .includes(:badge)
  end

  def student_ids
    students.map(&:id)
  end

  def students
    @students ||= IndexStudentCollection.new(User
      .unscoped_students_being_graded_for_course(course, team)
      .order_by_high_score, self)
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
      scheme = presenter.course.grade_scheme_elements.for_score(score)
    end

    def score
      self.cached_score_sql_alias
    end
    
    def display_name 
      presenter.display_name
    end
    
    def last_login 
      self.last_course_login(presenter.course)
    end

    def team
      presenter.team_memberships.find { |tm| tm.student_id == self.id }.try(:team)
    end

    def initialize(student, presenter)
      @presenter = presenter
      super student
    end
  end
end
