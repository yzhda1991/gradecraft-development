class InstitutionsController < ApplicationController
  before_action :ensure_admin?

  def index
    @institutions = Institution.all
  end

  def new
    @institution = Institution.new
  end

  def edit
    @institution = Institution.find params[:id]
  end

  def create
    @institution = Institution.new institution_params

    if @institution.save
      redirect_to institutions_path,
        notice: "Institution #{@institution.name} was successfully created"
    else
      render :new
    end
  end

  def update
    @institution = Institution.find params[:id]

    if @institution.update institution_params
      redirect_to edit_institution_path @institution,
        notice: "Institution #{@institution.name} was successfully updated"
    else
      render :edit
    end
  end

  private

  def institution_params
    params.require(:institution).permit :name, :has_site_license, :institution_type,
      providers_attributes: [:id, :name, :base_url, :providee_id, :consumer_key,
        :consumer_secret, :consumer_secret_confirmation]
  end
end
