class UsersController < ApplicationController
  include UsersHelper

  respond_to :html, :json

  before_filter :ensure_staff?, :except => [:activate, :activated, :edit_profile, :update_profile]
  before_filter :ensure_admin?, :only => [:all]
  skip_before_filter :require_login, :only => [:activate, :activated]

  def index
    @title = "All Users"
    @teams = current_course.teams
    @team = @teams.find_by(id: params[:team_id]) if params[:team_id]
    if params[:team_id].present?
      #TODO: should show TAs as well
      @users = @team.students
    else
      @users = current_course.users.includes(:courses, :teams)
    end
    respond_to do |format|
      format.html
      format.json { render json: @users }
      format.csv { send_data @users.to_csv }
      format.xls { send_data @users.to_csv(col_sep: "\t") }
    end
  end

  def new
    @title = "Create a New User"
    @teams = current_course.teams
    @courses = Course.all
    @user = User.new
    respond_with @user
  end

  def edit
    session[:return_to] = request.referer
    @teams = current_course.teams.alpha
    @user = current_course.users.find(params[:id])
    if @user.is_staff?(current_course)
      @courses = Course.all
      @teams_for_course = @user.teams.map do |t|
        t.id
      end
    elsif current_user_is_staff?
      @courses = Course.all
    end
    @course_membership = @user.course_memberships.where(course_id: current_course).first
    @title = "Editing #{@user.name}"
    @default_course_options = @user.courses
  end

  def create
    @teams = current_course.teams
    @user = User.create(params[:user].merge({password: generate_random_password}))

    if @user.valid?
      UserMailer.activation_needed_email(@user).deliver_now
      if @user.is_student?(current_course)
        redirect_to students_path,
          :notice => "#{term_for :student} #{@user.name} was successfully created!" and return
      elsif @user.is_staff?(current_course)
        redirect_to staff_index_path,
          :notice => "Staff Member #{@user.name} was successfully created!" and return
      end
    end
    expire_action :action => :index
    render :new
  end

  def update
    @user = User.find(params[:id])
    @course_membership = @user.course_memberships.where(course_id: current_course).first
    @teams = current_course.teams
    if @user.is_student?(current_course)
      @user.teams.set_for_course(current_course.id, params[:user][:course_team_ids])
    end
    @user.update_attributes(params[:user])
    if @user.save && @user.is_student?(current_course)
      redirect_to students_path, :notice => "#{term_for :student} #{@user.name} was successfully updated!"
    elsif @user.save && @user.is_staff?(current_course)
      redirect_to staff_index_path, :notice => "Staff Member #{@user.name} was successfully updated!"
    else
      redirect_to :edit
    end
  end

  def destroy
    @user = current_course.users.find(params[:id])
    @name = @user.name
    @user.destroy

    respond_to do |format|
      format.html { redirect_to users_url, :notice => "#{@name} was successfully deleted" }
      format.json { head :ok }
    end

  end

  def activate
    @user = User.load_from_activation_token(params[:id])
    @token = params[:id]
    redirect_to root_path, alert: "Invalid activation token. Please contact support to request a new one." and return unless @user
  end

  def activated
    @token = params[:token]
    @user = User.load_from_activation_token(@token)

    redirect_to root_path, alert: "Invalid activation token. Please contact support to request a new one." and return unless @user

    if @user.update_attributes params[:user]
      @user.activate!
      auto_login @user
      redirect_to dashboard_path, notice: "Welcome to GradeCraft!" and return
    end
    render :activate, alert: @user.errors.full_messages.first
  end

  # We don't allow students to edit their info directly - this is a mediated view
  def edit_profile
    @title = "Edit My Profile"
    @user = current_user
    @course_membership = @user.course_memberships.where(course_id: current_course).first
    @default_course_options = @user.courses
  end

  def update_profile
    @user = current_user
    @user.update_attributes(params[:user])
    redirect_to dashboard_path
  end

  def import
    @title = "Import Users"
  end

  #import users for class
  def upload
    if params[:file].blank?
      flash[:notice] = "File missing"
      redirect_to users_path
    else
      require 'csv'
      @successful = []
      @unsuccessful = []
      CSV.foreach(params[:file].tempfile, headers: true, skip_blanks: true) do |row|
        user = User.create do |u|
          u.first_name = row[0]
          u.last_name = row[1]
          u.username = row[2]
          u.email = row[3]
          u.password = generate_random_password
          u.course_memberships.build(course_id: current_course.id, role: "student")
        end

        if user.valid?
          UserMailer.activation_needed_email(user).deliver_now
          @successful << user
        else
          @unsuccessful << \
            { data: row.to_s, errors: user.errors.full_messages.join(", ") }
        end
      end
      render :import_results
    end
  end

  private

  def increment_predictor_views
    User.increment_counter(:predictor_views, current_user.id) if current_user && request.format.html?
  end
end
