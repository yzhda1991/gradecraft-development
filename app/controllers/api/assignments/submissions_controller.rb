require_relative "../../../services/creates_or_updates_submission"

class API::Assignments::SubmissionsController < ApplicationController
  before_action :ensure_student?

  # GET api/assignments/:assignment_id/submissions
  def show
    assignment = Assignment.find(params[:assignment_id])
    @submission = nil

    if assignment.is_individual?
      @submission = Submission.for_assignment_and_student(assignment.id, current_user.id).first
    else
      @submission = Submission.for_assignment_and_group(assignment.id, current_student.group_for_assignment(assignment).id).first
    end

    if @submission.present?
      render "api/assignments/submissions/submission", status: 200
    else
      render json: { data: nil, message: "No submission for assignment" }, status: 200
    end
  end

  # POST api/assignments/:assignment_id/submissions
  def create
    assignment = Assignment.find(params[:assignment_id])
    @submission = assignment.submissions.new merged_submission_params(assignment)

    if @submission.save #Put Service call here
      binding.pry
      Services::CreatesOrUpdatesSubmission.create_or_update_submission assignment @submission
      render "api/assignments/submissions/submission", status: 201
    else
      render "api/assignments/submissions/errors", status: 500
    end
  end

  # For updating draft submissions only, does not allow submitting
  # PUT api/assignments/:assignment_id/submissions/:id
  def update
    assignment = Assignment.find(params[:assignment_id])
    @submission = assignment.submissions.find_by_id(params[:id])

    if @submission.present?
      binding.pry
      if @submission.update_attributes submission_params #Put service call here
        Services::CreatesOrUpdatesSubmission.creates_or_updates_submission assignment, @submission

        render "api/assignments/submissions/submission", status: 200
      else
        render "api/assignments/submissions/errors", status: 500
      end
    else
      render json: { data: nil, errors: [ "Submission not found" ] }, status: 404
    end
  end

  private

  def merged_submission_params(assignment)
    if assignment.is_individual?
      submission_params.merge(student_id: current_student.id)
    else
      submission_params.merge(group_id: current_student.group_for_assignment(assignment).id)
    end
  end

  def submission_params
    params.require(:submission).permit(:assignment_id, :text_comment_draft)
  end
end
