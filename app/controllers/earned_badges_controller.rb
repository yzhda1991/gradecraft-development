class EarnedBadgesController < ApplicationController

  #Earned badges are to badges what grades are to assignments - the record of how what and how a student performed

  before_filter :ensure_staff?

  def index
    @badge = current_course.badges.find(params[:badge_id])
    redirect_to badge_path(@badge)
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
    @students = current_course.students
    @badge = current_course.badges.find(params[:badge_id])
    @title = "Editing Awarded #{@badge.name}"
    @earned_badge = @badge.earned_badges.find(params[:id])
    respond_with @earned_badge
  end

  def create
    @badge = current_course.badges.find(params[:badge_id])
    @earned_badge = current_course.earned_badges.new(params[:earned_badge])
    @earned_badge.assign_attributes(params[:earned_badge])
    @earned_badge.badge =  current_course.badges.find_by_id(params[:badge_id])
    @earned_badge.student =  current_course.students.find_by_id(params[:student])
    @earned_badge.student_visible = true

    respond_to do |format|
      if @earned_badge.save
        if @badge.point_total?
          # @mz TODO: add specs
          ScoreRecalculatorJob.new(user_id: @earned_badge.student_id, course_id: current_course.id).enqueue
        end
        NotificationMailer.earned_badge_awarded(@earned_badge.id).deliver_now
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
    @earned_badge.student_visible = true

    respond_to do |format|
      if @earned_badge.update_attributes(params[:earned_badge])
        if @badge.point_total?
          # @mz TODO: add specs
          ScoreRecalculatorJob.new(user_id: @earned_badge.student_id, course_id: current_course.id).enqueue
        end
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
      @team = current_course.teams.find params[:team_id]
      @students = current_course.students_by_team(@team)
    else
      @students = current_course.students
    end

    # build a new badge automatically if they can be earned at will
    if @badge.can_earn_multiple_times?
      @earned_badges = @students.map do |student|
        @badge.earned_badges.new(:student => student, :badge => @badge)
      end
    # otherwise build a new one only if it hasn't been earned
    else
      @earned_badges = @students.map do |student|
        @badge.earned_badges.where(:student_id => student).first || @badge.earned_badges.new(:student => student, :badge => @badge)
      end
    end
  end

  # ATTN
  def mass_earn
    @badge = current_course.badges.find(params[:id])
    @valid_earned_badges ||= parse_valid_earned_badges
    make_badges_student_visible
    send_earned_badge_notifications
    if @badge.point_total?
      update_student_point_totals
    end
    handle_mass_update_redirect
  end

  private
  def parse_valid_earned_badges
    params[:student_ids].inject([]) do |valid_earned_badges, student_id|
      earned_badge = EarnedBadge.create(student_id: student_id, badge: @badge)
      if earned_badge.valid?
        valid_earned_badges << earned_badge
      else
        logger.error earned_badge.errors.full_messages
      end
      valid_earned_badges
    end
  end

  def make_badges_student_visible
    @valid_earned_badges.each do |earned_badge|
      earned_badge.student_visible = true
      earned_badge.save
    end
  end

  def update_student_point_totals
    @valid_earned_badges.each do |earned_badge|
      # @mz TODO: add specs
      ScoreRecalculatorJob.new(user_id: earned_badge.student.id, course_id: current_course.id).enqueue
      logger.info "Updated student scores to include EarnedBadge ##{earned_badge[:id]}"
    end
  end

  def send_earned_badge_notifications
    @valid_earned_badges.each do |earned_badge|
      NotificationMailer.earned_badge_awarded(earned_badge.id).deliver_now
      logger.info "Sent an earned badge notification for EarnedBadge ##{earned_badge[:id]}"
    end
  end

  def handle_mass_update_redirect
    if @valid_earned_badges.any?
      redirect_to badge_path(@badge), notice: "The #{@badge.name} #{term_for :badge} was successfully awarded #{@valid_earned_badges.count} times"
    else
      redirect_to mass_award_badge_path(:id => @badge), notice: "No earned badges were sucessfully created."
    end
  end

  public

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
