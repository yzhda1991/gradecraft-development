class API::UsersController < ApplicationController
  before_action :ensure_admin?
  before_action :ensure_valid_search_criteria, only: :search

  # Search for all users by email or name
  # GET api/users
  def search
    @user = search_params[:email].nil? ? User.find_by(first_name: search_params[:first_name], last_name: search_params[:last_name]) : User.find_by_email(search_params[:email])
    if @user.present?
      render "api/users/search", status: 200
    else
      render json: { message: "Not found", success: false }, status: 404
    end
  end

  private

  def search_params
    params.permit(:email, :first_name, :last_name)
  end

  # Criteria is invalid if there is no email, first name, or last name
  def ensure_valid_search_criteria
    render json: { message: "Bad request", success: false }, status: 400 and return if search_params.to_h.blank?
  end
end
