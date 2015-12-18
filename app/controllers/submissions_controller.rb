class SubmissionsController < ApplicationController
  before_filter :ensure_staff?, only: [:show, :destroy]
  before_filter :save_referer, only: [:new, :edit]

  def new
    render :new, NewSubmissionPresenter.build(assignment_id: params[:assignment_id],
                                              course: current_course,
                                              group_id: params[:group_id],
                                              view_context: view_context)
  end

  def edit
    assignment = current_course.assignments.find(params[:assignment_id])
    submission = assignment.submissions.find params[:id]
    if current_user_is_staff?
      if assignment.has_groups?
        group = current_course.groups.find(params[:group_id])
        @title = "Editing #{group.name}'s Submission "
      else
        @title = "Editing #{submission.student.name}'s Submission"
      end
    end
    if current_user_is_student?
      @title = "Editing My Submission for #{assignment.name}"
      enforce_view_permission(submission)
    end
    render :edit, EditSubmissionPresenter.build({ id: params[:id],
                                                  assignment_id: params[:assignment_id],
                                                  course: current_course,
                                                  group_id: params[:group_id],
                                                  view_context: view_context })
  end

  def create
    @assignment = current_course.assignments.find(params[:assignment_id])
    if params[:submission] && params[:submission][:submission_files_attributes].present?
      submission_files = params[:submission][:submission_files_attributes]["0"]["file"]
      params[:submission].delete :submission_files_attributes
    end
    @submission = @assignment.submissions.new(params[:submission])
    @submission.student = current_student if current_user_is_student?
    if submission_files
      submission_files.each do |sf|
        if sf.size > MAX_UPLOAD_FILE_SIZE
          return redirect_to new_assignment_submission_path(@assignment, @submission), alert: "#{@assignment.name} not saved! #{sf.original_filename} was larger than the maximum #{MAX_UPLOAD_READABLE} file size."
        end
        @submission.submission_files.new(file: sf, filename: sf.original_filename[0..49])
      end
    end

    if @submission.save
      if current_user_is_student?
        redirect_to assignment_path(@assignment, :anchor => "fndtn-tabt3"), notice: "#{@assignment.name} was successfully submitted."
      else
        redirect_to (session.delete(:return_to) || assignment_path(@assignment)), notice: "#{@assignment.name} was successfully submitted."
      end
      if @assignment.is_individual? && current_user_is_student?
        NotificationMailer.successful_submission(@submission.id).deliver_now
      end
    elsif @submission.errors[:link].any?
      redirect_to new_assignment_submission_path(@assignment, @submission), notice: "Please provide a valid link for #{@assignment.name} submissions."
    else
      redirect_to new_assignment_submission_path(@assignment, @submission), alert: "#{@assignment.name} was not successfully submitted! Please try again."
    end
  end

  def show
    @assignment = current_course.assignments.find(params[:assignment_id])
    @submission = current_course.submissions.find(params[:id])
    @student = @submission.student
    if @assignment.is_individual?
      @title = "#{@student.first_name}'s #{@assignment.name} Submission (#{@assignment.point_total} points)"
    else
      @group = @submission.group
      @title = "#{@group.name}'s #{@assignment.name} Submission (#{@assignment.point_total} points)"
    end
  end

  def update
    @assignment = current_course.assignments.find(params[:assignment_id])
    if params[:submission] && params[:submission][:submission_files_attributes].present?
      submission_files = params[:submission][:submission_files_attributes]["0"]["file"]
      params[:submission].delete :submission_files_attributes
    end

    @submission = @assignment.submissions.find(params[:id])

    if submission_files
      submission_files.each do |sf|
        if sf.size > MAX_UPLOAD_FILE_SIZE
          return redirect_to new_assignment_submission_path(@assignment, @submission), alert: "#{@assignment.name} not saved! #{sf.original_filename} was larger than the maximum #{MAX_UPLOAD_READABLE} file size."
        end
        @submission.submission_files.new(file: sf, filename: sf.original_filename[0..49])
      end
    end

    respond_to do |format|
      if @submission.update_attributes(params[:submission])
        if current_user_is_student?
          NotificationMailer.updated_submission(@submission.id).deliver_now
          format.html { redirect_to assignment_path(@assignment, :anchor => "fndtn-tabt3"), notice: "Your submission for #{@assignment.name} was successfully updated." }
          format.json { render json: @assignment, status: :created, location: @assignment }
        else
          format.html { redirect_to assignment_submission_path(@assignment, @submission), notice: "#{@assignment.name} was successfully updated." }
        end
      elsif @submission.errors[:link].any?
        format.html { redirect_to edit_assignment_submission_path(@assignment, @submission), notice: "Please provide a valid link for #{@assignment.name} submissions." }
      else
        format.html { redirect_to edit_assignment_submission_path(@assignment, @submission), alert: "#{@assignment.name} was not successfully submitted! Please try again." }
        format.json { render json: @submission.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    assignment = current_course.assignments.find(params[:assignment_id])
    submission = current_course.submissions.find(params[:id])
    submission.destroy
    redirect_to assignment_path(assignment, notice: "Submission deleted")
  end
end
