require "active_lms"
require_relative "../../importers/badge_importers"

# rubocop:disable AndOr
class Badges::ImportersController < ApplicationController
  include OAuthProvider
  include CanvasAuthorization

  oauth_provider_param :importer_provider_id

  before_action :ensure_staff?
  before_action except: [:download, :index, :show, :upload] do |controller|
    controller.redirect_path \
      badge_badges_importers_path(params[:badge_id])
  end
  before_action :require_authorization, except: [:download, :index, :show, :upload]
  before_action :use_current_course, except: :download

  # GET /badges/:badge_id/badges/importers
  def index
    @badge = Badge.find params[:badge_id]
  end

  # GET /badges/:badge_id/badges/importers/:id
  def show
    @badge = Badge.find params[:badge_id]
    provider = params[:provider_id]

    render "#{provider}" if %w(canvas csv).include? provider
  end

  # GET /badges/:badge_id/badges/download
  # Sends a CSV file to the user with the current badges for all students
  # in the course for the particular badge
  def download
    badge = current_course.badges.find(params[:badge_id])
    respond_to do |format|
      format.csv do
        send_data BadgeExporter.new.export_badges(badge, current_course),
          filename: "#{ badge.name } Import Badges - #{ Date.today}.csv"
      end
    end
  end

  # POST /badges/:badge_id/badges/importers/:importer_provider_id/upload
  # rubocop:disable AndOr
  def upload
    @badge = @course.badges.find(params[:badge_id])

    if params[:file].blank?
      redirect_to badge_badges_importer_path(@badge, params[:importer_provider_id]),
        notice: "File is missing" and return
    end

    if (File.extname params[:file].original_filename) != ".csv"
      redirect_to badge_badges_importer_path(@badge, params[:importer_provider_id]),
        notice: "We're sorry, the badge import utility only supports .csv files. Please try again using a .csv file." and return
    end

    @result = CSVBadgeImporter.new(params[:file].tempfile, current_user, current_course)
      .import(@badge)
    render :import_results
  end

end
