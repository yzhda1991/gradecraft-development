class StudentsController < ApplicationController
  respond_to :html, :json

  before_filter :ensure_staff?,
    except: [:predictor, :grading_scheme, :badges, :teams, :syllabus ]
  before_filter :save_referer, only: [:recalculate]

  # Lists all students in the course,
  # broken out by those being graded and auditors
  def index
    @title = "#{(current_course.student_term).singularize} Roster"

    @teams = current_course.teams

    if params[:team_id].present?
      @team = current_course.teams.find_by(id: params[:team_id])
      @students = current_course.students_being_graded_by_team(@team)
    else
      @students = current_course.students
    end
  end

  # Displays all students flagged by the current user
  def flagged
    @title = "Flagged #{(current_course.student_term).pluralize}"
    @students = FlaggedUser.flagged current_course, current_user
  end

  # Course wide leaderboard - excludes auditors from view
  def leaderboard
    render :leaderboard, Students::LeaderboardPresenter.build(course: current_course, team_id: params[:team_id])
  end

  # Displaying student profile to instructors
  def show
    @events = Timeline.new(current_course).events_by_due_date
    self.current_student = current_course.students.where(id: params[:id]).first
    render "show", Info::DashboardCoursePlannerPresenter.build({
      student: current_student,
      assignments: current_course.assignments.chronological.includes(:assignment_type, :unlock_conditions),
      course: current_course,
      view_context: view_context
    })
  end

  # AJAX endpoint for student name search
  def autocomplete_student_name
    students = current_course.students.map do |u|
      { name: [u.first_name, u.last_name].join(" "), id: u.id }
    end
    render json: MultiJson.dump(students)
  end

  # Displaying the course grading scheme and professor's grading philosophy
  def grading_scheme
    self.current_student = current_course.students.where(id: params[:id]).first
    @grade_scheme_elements = current_course.grade_scheme_elements.order_by_highest_points
    @title = "Your Course Progress"
  end

  def teams
    student = params[:id].present? ? User.find(params[:id]) : current_student
    # make current_student a scope so the student profile tabs partial is displayed
    params[:student_id] = params[:id]
    @title = "#{term_for :teams}"
    @team = student.team_for_course(current_course)
    @teams = current_course.teams.order_by_rank.includes(:earned_badges)
  end

  # Display the grade predictor
  def predictor
    # id is used for api routes
    params[:student_id] = params[:id] if current_user_is_staff?
  end

  # All Admins to see all of one student's grades at once, proof for duplicates
  def grade_index
    student = current_course.students.find_by(id: params[:id])
    @grades = student.grades.where(course_id: current_course)
  end

  def recalculate
    @student = current_course.students.find_by(id: params[:id])

    # @mz TODO: add specs
    ScoreRecalculatorJob.new(user_id: @student.id,
      course_id: current_course.id).enqueue

    flash[:notice]="Your request to recalculate #{@student.name}'s grade is being processed. Check back shortly!"
    redirect_to session[:return_to] || student_path(@student)
  end
end
