class StudentsController < ApplicationController
  respond_to :html, :json

  before_filter :ensure_staff?, :except=> [:timeline, :predictor, :course_progress, :badges, :teams, :syllabus ]
  before_filter :save_referer, only: [:recalculate]

  #Lists all students in the course,
  #broken out by those being graded and auditors
  def index
    @title = "#{(current_course.user_term).singularize} Roster"

    @teams = current_course.teams

    if params[:team_id].present?
      @team = current_course.teams.find_by(id: params[:team_id])
      @students = current_course.students_being_graded_by_team(@team)
    else
      @students = current_course.students
    end
  end

  #Displays all students flagged by the current user
  def flagged
    @title = "Flagged #{(current_course.user_term).pluralize}"
    @students = FlaggedUser.flagged current_course, current_user
  end

  #Course wide leaderboard - excludes auditors from view
  def leaderboard
    @earned_badges_by_student_id = earned_badges_by_student_id
    @student_grade_schemes_by_id = [] #course_grade_scheme_by_student_id
    render :leaderboard, StudentLeaderboardPresenter.build(course: current_course, team_id: params[:team_id])
  end

  #Students' primary page: displays all assignments and
  #team challenges in course
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
    @events = current_course.timeline_events
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
    @team = current_student.team_for_course(current_course)
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
    @student = current_course.students.find_by(id: params[:student_id])

    # @mz todo: add specs
    ScoreRecalculatorJob.new(user_id: @student.id, course_id: current_course.id).enqueue

    flash[:notice]="Your request to recalculate #{@student.name}'s grade is being processed. Check back shortly!"
    redirect_to session[:return_to] || student_path(@student)
  end

  private

  # @mz todo: refactor and add specs, move out of controller
  def course_grade_scheme_by_student_id
    elements = GradeSchemeElement.unscoped.for_course(current_course).order_by_low_range.to_a
    @students.inject({}) do |memo, student|
      student_score = student.cached_score_sql_alias
      student_grade_scheme = GradeSchemeElement.for_score(student_score, elements)

      memo.merge student[:id] => student_grade_scheme
    end
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
end
