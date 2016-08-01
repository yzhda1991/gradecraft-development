require "active_lms"

class Grades::ImportersController < ApplicationController
  before_filter :ensure_staff?

  def assignments
    @assignment = Assignment.find params[:assignment_id]
    @provider = params[:importer_id]
    @course = syllabus.course(params[:id])
    @assignments = syllabus.assignments(params[:id])
  end

  # rubocop:disable AndOr
  # GET /assignments/:assignment_id/grades/download
  # Sends a CSV file to the user with the current grades for all students
  # in the course for the asisgnment
  def download
    assignment = current_course.assignments.find(params[:assignment_id])
    respond_to do |format|
      format.csv {
        send_data GradeExporter.new.export_grades(assignment, current_course.students),
          filename: "#{ assignment.name } Import Grades - #{ Date.today}.csv"
      }
    end
  end

  # GET /assignments/:assignment_id/grades/importers/:importer_id/courses
  def courses
    @assignment = Assignment.find params[:assignment_id]
    @provider = params[:importer_id]
    @courses = syllabus.courses
  end

  def grades
    @assignment = Assignment.find params[:assignment_id]
    @provider = params[:importer_id]
  end

  # GET /assignments/:assignment_id/grades/importers
  def index
    @assignment = Assignment.find params[:assignment_id]
  end

  # GET /assignments/:assignment_id/grades/importers/:id
  def show
    @assignment = Assignment.find params[:assignment_id]

    render params[:id]
  end

  # POST /assignments/:assignment_id/grades/importers/:importer_id/upload
  def upload
    @assignment = current_course.assignments.find(params[:assignment_id])

    if params[:file].blank?
      redirect_to assignment_grades_importer_path(@assignment, params[:importer_id]),
        notice: "File is missing"
    else
      @result = GradeImporter.new(params[:file].tempfile).import(current_course, @assignment)

      # @mz TODO: add specs
      grade_ids = @result.successful.map(&:id)
      enqueue_multiple_grade_update_jobs(grade_ids)

      render :import_results
    end
  end

  private

  # Schedule the `GradeUpdater` for all grades provided
  def enqueue_multiple_grade_update_jobs(grade_ids)
    grade_ids.each { |id| GradeUpdaterJob.new(grade_id: id).enqueue }
  end

  def syllabus
    @syllabus ||= ActiveLMS::Syllabus.new(@provider,
                                          ENV["#{@provider.upcase}_ACCESS_TOKEN"])
  end
end
