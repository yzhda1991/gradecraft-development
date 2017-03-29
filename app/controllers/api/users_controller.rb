class API::UsersController < ApplicationController
  before_action :ensure_admin?
  before_action :ensure_search_criteria, only: :search
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
    params.permit(:email, :first_name, :last_name, :username)
  end

  # TODO: Extract logic into a service
  def find_user
    if search_params[:email].present?
      user = User.find_by_insensitive_email(search_params[:email])
      @users = [user] unless user.nil?
    elsif search_params[:username].present?
      user = User.find_by_insensitive_username(search_params[:username])
      @users = [user] unless user.nil?
    else  # search by name
      @users = User.find_by_insensitive_last_name(search_params[:last_name]) if search_params[:first_name].blank?
      @users = User.find_by_insensitive_first_name(search_params[:first_name]) if search_params[:last_name].blank?
      @users ||= User.find_by_insensitive_full_name(search_params[:first_name], search_params[:last_name])
    end
  end

  # rubocop:disable AndOr
  # Ensure that there are search terms
  def ensure_search_criteria
    render json: { message: "Bad request", success: false }, status: 400 and return if search_params.to_h.blank?
  end
end
