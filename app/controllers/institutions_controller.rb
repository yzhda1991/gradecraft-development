class InstitutionsController < ApplicationController
  before_action :ensure_admin?

  def new
    @institution = Institution.new
  end

  def create
    @institution = Institution.new institution_params
    
    if @institution.save
      redirect_to courses_path,
        notice: "Institution #{@institution.name} was successfully created"
    else
      render :new
    end
  end

  private

  def institution_params
    params.require(:institution).permit :name, :has_site_license,
      providers_attributes: [:id, :name, :base_url, :providee_id, :consumer_key,
        :consumer_secret, :consumer_secret_confirmation]
  end
end
