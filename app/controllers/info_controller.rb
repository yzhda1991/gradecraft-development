class InfoController < ApplicationController
  helper_method :sort_column, :sort_direction, :predictions

  before_filter :ensure_staff?, :except => [ :dashboard, :timeline_events ]
  before_action :find_team, only: [ :awarded_badges, :choices, :resubmissions ]
  before_action :find_students, only: [ :awarded_badges, :choices  ]

  # Displays instructor dashboard, with or without Team Challenge dates
  def dashboard
    #checking to see if the course uses the interactive timeline -
    # if not sending students to their syllabus, and the staff to top 10
    if current_course.use_timeline?
      render :dashboard
    else
      if current_user_is_student?
        redirect_to syllabus_path
      else
        redirect_to top_10_path
      end
    end
  end

  def timeline_events
    @events = current_course.timeline_events
    render(:partial => 'info/timeline', :handlers => [:jbuilder], :formats => [:js])
  end

  def awarded_badges
    @title = "Awarded #{term_for :badges}"
    @teams = current_course.teams
  end

  # Displaying all ungraded, graded but unreleased, and in progress assignment submissions in the system
  def grading_status
    @title = "Grading Status"
    grades = current_course.grades
    unrealeased_grades = grades.not_released
    in_progress_grades = grades.in_progress
    @ungraded_submissions = current_course.submissions.ungraded.includes(:assignment, :grade, :student, :group, :submission_files)
    @ungraded_submissions_by_assignment = @ungraded_submissions.group_by(&:assignment)
    @unreleased_grades_by_assignment = unrealeased_grades.group_by(&:assignment)
    @in_progress_grades_by_assignment = in_progress_grades.group_by(&:assignment)
    @count_unreleased = unrealeased_grades.not_released.count
    @count_ungraded = @ungraded_submissions.count
    @count_in_progress = in_progress_grades.count
  end

  # Displaying all resubmisisons
  def resubmissions
    @title = "Resubmitted Assignments"
    resubmissions = current_course.submissions.resubmitted

    @teams = current_course.teams
    if @team
      @students ||= @team.students.pluck(:id)
      @resubmissions = resubmissions.where(student_id: @students)
    else
      @resubmissions = resubmissions
    end

    @resubmission_count = @resubmissions.count
  end

  def ungraded_submissions
    @title = "Ungraded #{term_for :assignment} Submissions"
    @ungraded_submissions = current_course.submissions.ungraded.date_submitted.includes(:assignment, :student, :submission_files)
    @count_ungraded = @ungraded_submissions.count
  end

  # Displaying the top 10 and bottom 10 students for quick overview
  def top_10
    @title = "Top 10/Bottom 10"
    students = current_course.students_being_graded
    students.each do |s|
      s.score = s.cached_score_for_course(current_course)
      s.team_for_course(current_course)
    end
    @students = students.to_a.sort_by {|student| student.score}.reverse
    if @students.length <= 10
      @top_ten_students = students
    elsif @students.length <= 20
      @top_ten_students = @students[0..9]
      @count = @students.length
      @bottom_ten_students = @students[10..@count]
    else
      @top_ten_students = @students[0..9]
      @bottom_ten_students = @students[-10..-1]
    end
  end

  # Displaying per assignment summary outcome statistics
  def per_assign
    @assignment_types = current_course.assignment_types.includes(:assignments)
    @title = "#{term_for :assignment} Analytics"
  end

  def final_grades
    respond_to do |format|
      format.csv { send_data CourseGradeExporter.new.final_grades_for_course current_course }
    end
  end

  def gradebook
    GradebookExporterJob.new(user_id: current_user.id, course_id: current_course.id).enqueue

    flash[:notice]="Your request to export the gradebook for \"#{current_course.name}\" is currently being processed. We will email you the data shortly."
    redirect_back_or_default
  end

  def multiplied_gradebook
    MultipliedGradebookExporterJob
      .new(user_id: current_user.id, course_id: current_course.id).enqueue

    flash[:notice]="Your request to export the multiplied gradebook \
                    for \"#{current_course.name}\" is currently being processed. \
                    We will email you the data shortly."
    redirect_back_or_default
  end

  #downloadable grades for course with  export
  def research_gradebook
    # @mz TODO: add specs
    @grade_export_job = GradeExportJob.new(user_id: current_user.id, course_id: current_course.id)
    @grade_export_job.enqueue

    flash[:notice]="Your request to export grade data from course \"#{current_course.name}\" is currently being processed. We will email you the data shortly."
    redirect_to courses_path
  end

  # Chart displaying all of the student weighting choices thus far
  def choices
    @title = "#{current_course.weight_term} Choices"
    @assignment_types = current_course.assignment_types
    @teams = current_course.teams
  end

  def assignment_structure
    respond_to do |format|
      format.csv { send_data AssignmentStructureExporter.new.assignment_structure current_course }
    end
  end

  private

  def find_team
    @team = current_course.teams.find_by(id: params[:team_id]) if params[:team_id]
  end

  def find_students
    if @team
      @students = current_course.students_being_graded_by_team(@team)
    else
      @students = current_course.students_being_graded
    end
  end
end
