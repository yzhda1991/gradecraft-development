require_relative "../services/deletes_submission_draft_content"

class SubmissionsController < ApplicationController
  before_action :ensure_not_observer?
  before_action :ensure_staff?, only: [:show, :destroy]
  before_action :save_referer, only: [:new, :edit]

  def show
    @submission = Submission.find(params[:id])
    @grade = @submission.grade
    presenter = Submissions::ShowPresenter.new(presenter_attrs_with_id)
    authorize! :read, presenter.submission
    render :show, locals: { presenter: presenter }
  end

  def new
    @assignment = current_course.assignments.find(params[:assignment_id])
    presenter = Submissions::NewPresenter.new(base_presenter_attrs)
    render :new, presenter.render_options
  end

  def create
    assignment = current_course.assignments.find(params[:assignment_id])
    submission = assignment.submissions.new(submission_params.merge(submitted_at: DateTime.now))

    if submission.save
      submission.check_and_set_late_status!
      redirect_to = (session.delete(:return_to) || assignment_path(assignment))
      if current_user_is_student?
        NotificationMailer.successful_submission(submission.id).deliver_now if assignment.is_individual?
        redirect_to = assignment_path(assignment, anchor: "tabt1")
      end
      # rubocop:disable AndOr
      redirect_to redirect_to, notice: "#{assignment.name} was successfully submitted." and return
    end
    render :new, Submissions::NewPresenter.build(assignment_id: params[:assignment_id],
                                              submission: submission,
                                              student: submission.student,
                                              course: current_course,
                                              group_id: submission.group_id,
                                              view_context: view_context)
  end

  def edit
    @assignment = current_course.assignments.find(params[:assignment_id])
    presenter = Submissions::EditPresenter.new(presenter_attrs_with_id)
    ensure_editable presenter.submission, @assignment or return
    authorize! :update, presenter.submission
    render :edit, locals: { presenter: presenter }
  end

  def update
    assignment = current_course.assignments.find(params[:assignment_id])
    submission = assignment.submissions.find(params[:id])
    ensure_editable submission, assignment or return

    submission_was_draft = submission.unsubmitted?
    respond_to do |format|
      if submission.update_attributes(submission_params.merge(submitted_at: DateTime.now)) && Services::DeletesSubmissionDraftContent.for(submission).success?
        submission.check_and_set_late_status! unless submission.will_be_resubmitted?
        path = assignment.has_groups? ? { group_id: submission.group_id } :
          { student_id: submission.student_id }
        redirect_to = assignment_submission_path(assignment, submission, path)
        if current_user_is_student?
          send_notification(submission.id, submission_was_draft) if assignment.is_individual?
          redirect_to = assignment_path(assignment, anchor: "tabt1")
        end
        format.html { redirect_to redirect_to, notice: "Your changes for #{assignment.name} were successfully submitted." }
        format.json { render json: assignment, status: :created, location: assignment }
      else
        format.html do
          render :edit, Submissions::EditPresenter.build(id: params[:id],
                                                      assignment_id: params[:assignment_id],
                                                     course: current_course,
                                                     group_id: submission.group_id,
                                                     submission: submission,
                                                     view_context: view_context)
        end
        format.json { render json: submission.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    assignment = current_course.assignments.find(params[:assignment_id])
    assignment.submissions.find(params[:id]).destroy
    redirect_to assignment_path(assignment, notice: "Submission deleted")
  end

  private

  def send_notification(submission_id, submission_was_draft)
    if submission_was_draft
      NotificationMailer.successful_submission(submission_id).deliver_now
    else
      NotificationMailer.updated_submission(submission_id).deliver_now
    end
  end

  def ensure_editable(submission, assignment)
    redirect_to assignment_path(assignment, anchor: "tabt1"),
      notice: "We're sorry, this assignment is currently being graded. You cannot change your submission again until your grade has been released." \
      and return if !SubmissionProctor.new(submission).open_for_editing? assignment, current_user
    return true
  end

  def presenter_attrs_with_id
    base_presenter_attrs.merge id: params[:id]
  end

  def base_presenter_attrs
    {
      assignment_id: params[:assignment_id],
      course: current_course,
      group_id: params[:group_id],
      view_context: view_context
    }
  end

  def submission_params
    params.require(:submission).permit :assignment_id, :group_id, :link,
    :student_id, :text_comment, :submitted_at, :course_id,
    submission_files_attributes: [:id, file: []]
  end
end
