class StudentsController < ApplicationController
  helper_method :predictions

  respond_to :html, :json

  before_filter :ensure_staff?, :except=> [:timeline, :predictor, :course_progress, :badges, :teams, :syllabus ]

  #Lists all students in the course, broken out by those being graded and auditors
  def index
    @title = "#{(current_course.user_term).singularize} Roster"

    @teams = current_course.teams

    if team_filter_active?
      @team = current_course.teams.find_by(id: params[:team_id])
      @students = current_course.students_being_graded_by_team(@team)
    else
      @students = current_course.students
    end
  end

  def flagged
    @title = "Flagged #{(current_course.user_term).pluralize}"
    @students = FlaggedUser.flagged current_course, current_user
  end

  # @mz todo: 
  #Course wide leaderboard - excludes auditors from view
  def leaderboard
    # before_filter :ensure_staff?
    @title = "Leaderboard"

    @teams = current_course.teams

    if team_filter_active?
      # fetch user ids for all students in the active team
      @team = @teams.find_by(id: params[:team_id]) if params[:team_id]
      @students = User.unscoped_students_being_graded_for_course_by_team(current_course, @team).order_by_high_score
    else
      # fetch user ids for all students in the course, regardless of team
      # cached_score_sql_alias is coming from custom unscoped_students_being_graded_for_course SQL

      @students = User.unscoped_students_being_graded_for_course(current_course).order_by_high_score
    end

    @student_ids = @students.collect {|s| s[:id] }
    @teams_by_student_id = teams_by_student_id
    @earned_badges_by_student_id = earned_badges_by_student_id
    @student_grade_schemes_by_id = course_grade_scheme_by_student_id
  end

  #Displaying the list of assignments and team challenges for the semester
  def syllabus
    @assignment_types = current_course.assignment_types.includes(:assignments)
    @assignments = current_course.assignments
    @student = current_student
  end

  # Course timeline, displays all assignments that are determined by the instructor to belong on the timeline + team challenges if present
  def timeline
    if current_user_is_student?
      redirect_to dashboard_path
    end
    if current_course.team_challenges?
      @events = current_course.assignments.timelineable.with_dates.to_a + current_course.challenges.with_dates.to_a + current_course.events.with_dates.to_a
    else
      @events = current_course.assignments.timelineable.with_dates.to_a + current_course.events.with_dates.to_a
    end
  end

  #Displaying student profile to instructors
  def show
    self.current_student = current_course.students.where(id: params[:id]).first
    @student = current_student
    @student.team_for_course(current_course) if current_course.has_teams?
    @assignments = current_course.assignments
    @assignment_types = current_course.assignment_types
    @display_sidebar = true
  end

  # AJAX endpoint for student name search
  def autocomplete_student_name
    students = current_course.students.map do |u|
      { :name => [u.first_name, u.last_name].join(' '), :id => u.id }
    end
    render json: MultiJson.dump(students)
  end

  # Displaying the course grading scheme and professor's grading philosophy
  def course_progress
    @grade_scheme_elements = current_course.grade_scheme_elements
    @title = "Your Course Progress"
    @display_sidebar = true
  end

  def teams
    @title = "#{term_for :teams}"
    @display_sidebar = true
  end

  def badges
    @title = "#{term_for :badges}"

    @earned_badges = current_student.student_visible_earned_badges(current_course).includes(:badge_files)
    @unearned_badges = current_student.student_visible_unearned_badges(current_course).includes(:badge_files, :unlock_conditions, :unlock_keys)
    @badges = [] << @earned_badges.collect(&:badge) << @unearned_badges

    @badges = @badges.flatten.uniq.sort_by(&:position)
    @earned_badges_by_badge_id ||= earned_badges_by_badge_id
    @display_sidebar = true
  end

  # Display the grade predictor
  #   students - style blocks to fill entire page, render layout with no sidebar
  #   staff - render standard laout with sidebar
  def predictor
    if current_user_is_student?
      @fullpage = true
      render :layout => 'predictor'
    end
  end

  #All Admins to see all of one student's grades at once, proof for duplicates
  def grade_index
    @grades = current_student.grades.where(:course_id => current_course)
    @display_sidebar = true
  end

  def recalculate
    session[:return_to] = request.referer
    @student = current_course.students.find_by(id: params[:student_id])

    # @mz TODO: add specs
    ScoreRecalculatorJob.new(user_id: @student.id, course_id: current_course.id).enqueue

    flash[:notice]="Your request to recalculate #{@student.name}'s grade is being processed. Check back shortly!"
    redirect_to session[:return_to] || student_path(@student)
  end

  protected

  # @mz todo: refactor and add specs, move out of controller
  def course_grade_scheme_by_student_id
    @students.inject({}) do |memo, student|
      student_score = student.cached_score_sql_alias
      student_grade_scheme = nil

      course_grade_scheme_elements.each do |grade_scheme|
        if student_score >= grade_scheme.low_range and student_score <= grade_scheme.high_range
          student_grade_scheme = grade_scheme
          break
        end
      end

      if student_grade_scheme.nil? and course_grade_scheme_elements.present?
        if student_score < course_grade_scheme_elements.first.low_range
          student_grade_scheme = GradeSchemeElement.new(level: "Not yet on board")
        elsif student_score > course_grade_scheme_elements.last.high_range
          student_grade_scheme = course_grade_scheme_elements.last
        end
      end

      memo.merge student[:id] => student_grade_scheme
    end
  end

  def course_grade_scheme_elements
    @course_grade_scheme_elements ||= GradeSchemeElement.unscoped.where(course_id: current_course.id).order("low_range ASC")
  end

  def earned_badges_by_badge_id
    @earned_badges.inject({}) do |memo, earned_badge|
      if memo[earned_badge.badge.id]
        memo[earned_badge.badge.id] << earned_badge
      else
        memo[earned_badge.badge.id] = [earned_badge]
      end
      memo
    end
  end

  def earned_badges_by_student_id
    @earned_badges_by_student_id ||= student_earned_badges_for_entire_course.inject({}) do |memo, earned_badge|
      student_id = earned_badge.student_id
      if memo[student_id]
        memo[student_id] << earned_badge
      else
        memo[student_id] = [earned_badge]
      end
      memo
    end
  end

  def student_earned_badges_for_entire_course
    @student_earned_badges ||= EarnedBadge.where(course: current_course).where("student_id in (?)", @student_ids).includes(:badge)
  end

  def teams_by_student_id
    @teams_by_student_id ||= team_memberships_for_course.inject({}) do |memo, tm|
      memo.merge tm.student_id => tm.team
    end
  end

  def team_memberships_for_course
    @team_memberships_for_course ||= TeamMembership.joins(:team)
      .where("teams.course_id = ?", current_course.id)
      .where(student_id: @student_ids)
      .includes(:team)
  end

  def team_filter_active?
    params[:team_id].present?
  end

end
