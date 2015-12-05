class CoursesController < ApplicationController
  include CoursesHelper

  before_filter :ensure_staff?, :except => [:timeline]

  def index
    @title = "Course Index"
    @courses = Course.all
  end

  def show
    @title = "Course Settings"
    @course = Course.find(params[:id])
  end

  def new
    @title = "Create a New Course"
    @course = Course.new
  end

  def edit
    @title = "Editing Basic Settings"
    @course = Course.find(params[:id])
  end

  # Important for instructors to be able to copy one course's structure into a new one - does not copy students or grades
  def copy
    @course = Course.find(params[:id])
    new_course = @course.dup
    new_course.name.prepend("Copy of ")
    new_course.save
    if @course.badges.present?
      @course.badges.each do |b|
        nb = b.dup
        nb.course_id = new_course.id
        nb.save
      end
    end
    if @course.assignment_types.present?
      @course.assignment_types.each do |at|
        nat = at.dup
        nat.course_id = new_course.id
        nat.save
        at.assignments.each do |a|
          na = a.dup
          na.assignment_type_id = nat.id
          na.course_id = new_course.id
          na.save
          if a.assignment_score_levels.present?
            a.assignment_score_levels.each do |asl|
              nasl = asl.dup
              nasl.assignment_id = na.id
              nasl.save
            end
          end
          if a.rubric.present?
            new_rubric = a.rubric.dup
            new_rubric.assignment_id = na.id
            new_rubric.save
            if a.rubric.metrics.present?
              a.rubric.metrics.each do |metric|
                new_metric = metric.dup
                new_metric.rubric_id = new_rubric.id
                new_metric.add_default_tiers = false
                new_metric.save
                if metric.tiers.present?
                  metric.tiers.each do |tier|
                    new_tier = tier.dup
                    new_tier.metric_id = new_metric.id
                    new_tier.save
                    if tier.tier_badges.present?
                      tier.tier_badges.each do |tier_badge|
                        new_tier_badge = tier_badge.dup
                        new_tier_badge.tier_id = new_tier.id
                        badge = tier_badge.badge
                        new_badge = new_course.badges.where(:name => badge.name).first
                        new_tier_badge.badge_id = new_badge.id
                        new_tier_badge.save
                      end
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    if @course.challenges.present?
      @course.challenges.each do |c|
        nc = c.dup
        nc.course_id = new_course.id
        nc.save
      end
    end
    if @course.grade_scheme_elements.present?
      @course.grade_scheme_elements.each do |gse|
        ngse = gse.dup
        ngse.course_id = new_course.id
        ngse.save
      end
    end
    respond_to do |format|
      if new_course.save
        if ! current_user_is_admin?
          new_course.course_memberships.create(:user_id => current_user.id,
                                                :role => current_user.role(current_course))
        end
        session[:course_id] = new_course.id
        format.html { redirect_to course_path(new_course.id), notice: "#{@course.name} successfully copied" }
      else
        redirect_to courses_path, alert: "#{@course.name} was not successfully copied"
      end
    end

  end

  def create
    @course = Course.new(params[:course])
    @title = "Create a New Course"

    respond_to do |format|
      if @course.save
        if ! current_user_is_admin?
          @course.course_memberships.create(user_id: current_user.id,
                                            role: current_user.role(current_course))
        end
        session[:course_id] = @course.id
        bust_course_list_cache current_user
        format.html { redirect_to course_path(@course), notice: "Course #{@course.name} successfully created" }
      else
        format.html { render action: "new" }
      end
    end
  end

  def update
    @course = Course.find(params[:id])
    @title = "Editing Basic Settings"

    respond_to do |format|
      if @course.update_attributes(params[:course])
        bust_course_list_cache current_user
        format.html { redirect_to @course, notice: "Course #{@course.name} successfully updated" }
      else
        format.html { render action: "edit" }
      end
    end
  end

  def timeline_settings
    @course = current_course
    @assignments = @course.assignments.includes(:assignment_type)
    @title = "Timeline Settings"
  end

  def timeline_settings_update
    @course = current_course
    if @course.update_attributes(params[:course])
      redirect_to dashboard_path
    else
      render action: "timeline_settings", :course => @course
    end
  end

  def predictor_settings
    @course = current_course
    @assignments = current_course.assignments.includes(:assignment_type)
    @title = "Grade Predictor Settings"
  end

  def predictor_settings_update
    @course = current_course
    if @course.update_attributes(params[:course])
      respond_with @course
    else
      render action: "predictor_settings", :course => @course
    end
  end

  def destroy
    @course = Course.find(params[:id])
    @name = @course.name
    @course.destroy

    respond_to do |format|
      format.html { redirect_to courses_url, notice: "Course #{@name} successfully deleted" }
    end
  end

  def export_earned_badges
    @course = current_course
    respond_to do |format|
      format.csv { send_data EarnedBadgeExporter.new.earned_badges_for_course current_course.earned_badges }
    end
  end

end
