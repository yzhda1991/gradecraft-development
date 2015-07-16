class EarnedBadgesController < ApplicationController

  #Earned badges are to badges what grades are to assignments - the record of how what and how a student performed

  before_filter :ensure_staff?, :except => :toggle_shared

  def index
    @title = "Awarded #{term_for :badges}"
    @badge = current_course.badges.find(params[:badge_id])
    redirect_to badge_path(@badge)
  end

  # Displays the students earned badges
  def my_badges
    @title = "Awarded #{term_for :badges}"
    @earned_badges = @earnable.earned_badges
  end

  def show
    @badge = current_course.badges.find(params[:badge_id])
    @earned_badge = @badge.earned_badges.find(params[:id])
    @student = @earned_badge.student
    @title = "#{@student.name}'s #{@badge.name} #{term_for :badge}"
  end

  def new
    @badge = current_course.badges.find(params[:badge_id])
    @title = "Award #{@badge.name}"
    @earned_badge = @badge.earned_badges.new
    @students = current_course.students
  end

  def edit
    @title = "Editing Awarded #{term_for :badge}"
    @students = current_course.students
    @badge = current_course.badges.find(params[:badge_id])
    @earned_badge = @badge.earned_badges.find(params[:id])
    respond_with @earned_badge
  end

  def create
    @badge = current_course.badges.find(params[:badge_id])
    @earned_badge = current_course.earned_badges.new(params[:earned_badge])
    @earned_badge.assign_attributes(params[:earned_badge])
    @earned_badge.badge =  current_course.badges.find_by_id(params[:badge_id])
    @earned_badge.student =  current_course.students.find_by_id(params[:student])
    respond_to do |format|
      if @earned_badge.save
        NotificationMailer.earned_badge_awarded(@earned_badge.id).deliver
        format.html { redirect_to badge_path(@badge), notice: "The #{@badge.name} #{term_for :badge} was successfully awarded to #{@earned_badge.student.name}" }
      else
        @title = "Award #{@badge.name}"
        format.html { render action: "new" }
        format.json { render json: @earned_badge.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    @badges = current_course.badges
    @badge = current_course.badges.find(params[:badge_id])
    @earned_badge = @badge.earned_badges.find(params[:id])

    respond_to do |format|
      if @earned_badge.update_attributes(params[:earned_badge])
        expire_fragment "earned_badges"
        format.html { redirect_to badge_path(@badge), notice: "#{@earned_badge.student.name}'s #{@badge.name} #{term_for :badge} was successfully updated." }
        format.json { head :ok }
      else
        format.html { render action: "edit" }
        format.json { render json: @earned_badge.errors, status: :unprocessable_entity }
      end
    end
  end

  # Quickly award a badge to multiple students
  def mass_edit
    @badge = current_course.badges.find(params[:id])
    @title = "Quick Award #{@badge.name}"
    @teams = current_course.teams

    if params[:team_id].present?
      @team = current_course.teams.find_by(id: params[:team_id])
      @students = current_course.students_by_team(@team)
    else
      @students = current_course.students
    end

    if @badge.can_earn_multiple_times?
      @earned_badges = @students.map do |s|
        @badge.earned_badges.new(:student => s, :badge => @badge)
      end
    else
      @earned_badges = @students.map do |s|
        @badge.earned_badges.where(:student_id => s).first || @badge.earned_badges.new(:student => s, :badge => @badge)
      end
    end
  end

  def mass_update
    @badge = current_course.badges.find(params[:id])
    if @badge.update_attributes(params[:badge])
      NotificationMailer.earned_badge_awarded(@earned_badge.id).deliver
      respond_with @badge
    else
      redirect_to :mass_edit
    end
  end

  # Display a chart of all badges earned in the course
  def chart
    @badges = current_course.badges
    @students = current_course.students
  end

  def destroy
    @badge = current_course.badges.find(params[:badge_id])
    @name = "#{@badge.name}"
    @earned_badge = @badge.earned_badges.find(params[:id])
    @student_name = "#{@earned_badge.student.name}"
    @earned_badge.destroy
    expire_fragment "earned_badges"
    redirect_to @badge, notice: "The #{@badge.name} #{term_for :badge} has been taken away from #{@student_name}."
  end

end
