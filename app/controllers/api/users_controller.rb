class API::UsersController < ApplicationController
  before_action :ensure_admin?
  before_action :ensure_valid_search_criteria, only: :search
  before_action :find_user, only: :search

  # Search for all users by email or name
  # GET api/users/search
  def search
    if @users.present?
      render "api/users/search", status: 200
    else
      render json: { message: "Not found", success: false }, status: 404
    end
  end

  private

  def search_params
    params.permit(:email, :first_name, :last_name)
  end

  # TODO: Possibly should be extracted into a service
  def find_user
    if search_params[:email].blank?
      @users = User.find_by_insensitive_last_name(search_params[:last_name]) if search_params[:first_name].blank?
      @users ||= User.find_by_insensitive_full_name(search_params[:first_name], search_params[:last_name])
    else
      user = User.find_by_insensitive_email(search_params[:email])
      @users = user.nil? ? [] : [user]
    end
  end

  # rubocop:disable AndOr
  # Criteria is invalid if there is no email, first name, or last name
  def ensure_valid_search_criteria
    render json: { message: "Bad request", success: false }, status: 400 and return if search_params.to_h.blank?
  end
end
