require "active_lms"
require "importers/badge_importers.rb"
# require_relative "../../services/imports_lms_grades"

# rubocop:disable AndOr
class Badges::ImportersController < ApplicationController
  include OAuthProvider
  include CanvasAuthorization

  before_action :ensure_staff?
  before_action except: [:download, :index, :show, :upload] do |controller|
    controller.redirect_path \
      badges_importers_path(params[:badge_id])
  end
  before_action :use_current_course, except: :download

  # GET /assignments/:assignment_id/badges/importers
  def index
    @badge = Badge.find params[:badge_id]
  end

  # GET /assignments/:assignment_id/grades/importers/:id
  def show
    @badge = Badge.find params[:badge_id]
    provider = params[:provider_id]

    render "#{provider}" if %w(canvas csv).include? provider
  end

  # GET /assignments/:assignment_id/grades/download
  # Sends a CSV file to the user with the current grades for all students
  # in the course for the asisgnment
  def download
    badge = current_course.badges.find(params[:badge_id])
    respond_to do |format|
      format.csv do
        send_data BadgeExporter.new.export_badges(badge, current_course.students),
          filename: "#{ badge.name } Import Badges - #{ Date.today}.csv"
      end
    end
  end

  # POST /assignments/:assignment_id/grades/importers/:importer_provider_id/upload
  # rubocop:disable AndOr
  def upload
    @badge = @course.badges.find(params[:badge_id])

    if params[:file].blank?
      # redirect_to assignment_grades_importe_path(@assignment, params[:importer_provider_id]),
      redirect_to badges_path,
        notice: "File is missing" and return
    end

    if (File.extname params[:file].original_filename) != ".csv"
      # redirect_to assignment_grades_importer_path(@assignment, params[:importer_provider_id]),
      redirect_to badges_path,
        notice: "We're sorry, the grade import utility only supports .csv files. Please try again using a .csv file." and return
    end

    binding.pry

    CSVBadgeImporter

    @result = CSVBadgeImporter.new(params[:file].tempfile)
      .import(current_course, @badge)

    # grade_ids = @result.successful.map(&:id)
    # enqueue_multiple_grade_update_jobs(grade_ids)

    render :import_results
  end

end
