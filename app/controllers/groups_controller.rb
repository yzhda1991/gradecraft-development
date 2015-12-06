class GroupsController < ApplicationController
  before_filter :ensure_staff?, only: [:index, :review, :destroy]

  before_action :find_group, only: [:show, :review, :edit, :update, :destroy]

  def index
    @pending_groups = current_course.groups.pending
    @approved_groups = current_course.groups.approved
    @rejected_groups = current_course.groups.rejected
    @assignments = current_course.assignments.group_assignments
    @title = current_course.group_term.pluralize
  end

  def show
    @title = "#{@group.name}"
    @assignments = current_course.assignments.group_assignments
  end

  def new
    @group = current_course.groups.new
    @assignments = current_course.assignments.group_assignments
    @title = "Start a #{term_for :group}"
    @other_students = potential_team_members
  end

  def review
    @title = "Reviewing #{@group.name}"
  end

  def create
    @group = current_course.groups.new(params[:group])
    @assignments = current_course.assignments.group_assignments
    @group.students << current_student if current_user_is_student?
    if current_user_is_student?
      @group.approved = "Pending"
    else
      @group.approved = "Approved"
    end
    respond_to do |format|
      if @group.save
        format.html { respond_with @group, notice: "#{@group.name} #{term_for :group} successfully created"  }
      else
        @other_students = potential_team_members
        format.html { render :action => "new", :group => @group  }
      end
    end
  end

  def edit
    @other_students = potential_team_members
    @assignments = current_course.assignments.group_assignments
    @title = "Editing #{@group.name}"
  end

  def update
    @assignments = current_course.assignments.group_assignments
    respond_to do |format|
      if @group.update_attributes(params[:group])
        format.html { respond_with @group, notice: "#{@group.name} #{term_for :group} successfully updated" }
      else
        @other_students = potential_team_members
        format.html { render :action => "edit", :group => @group }
      end
    end
  end

  def destroy
    @name = @group.name
    @group.destroy

    respond_to do |format|
      format.html { redirect_to groups_path, notice: "#{@name} #{term_for :group} successfully deleted" }
    end
  end

  private 

  def potential_team_members
    current_course.students.where.not(id: current_user.id)
  end

  def find_group
    @group = current_course.groups.includes(:proposals).find(params[:id])
  end

end
