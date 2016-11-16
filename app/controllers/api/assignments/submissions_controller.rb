class API::Assignments::SubmissionsController < ApplicationController
  before_action :ensure_student?

  def show
    assignment = Assignment.find(params[:assignment_id])
    submission = assignment.submissions.find_by(student_id: current_user.id)

    if submission.present?
      render json: { submission: submission, message: "Found an existing submission draft" }, status: 200
    else
      render json: { submission: assignment.submissions.new, message: "No existing submission draft was found" }, status: 404
    end
  end

  def create
    assignment = Assignment.find(params[:assignment_id])
    submission = assignment.submissions.new submission_params.merge(student_id: current_user.id)

    if submission.save
      render json: { submission: submission, message: "Successfully created a submission draft" }, status: 201
    else
      render json: { message: "Failed to create submission" }, status: 500
    end
  end

  def update
    assignment = Assignment.find(params[:assignment_id])
    submission = assignment.submissions.find_by_id(params[:id])

    if submission.present?
      if submission.update_attributes submission_params
        render json: { submission: submission, message: "Successfully updated a submission draft" }, status: 200
      else
        render json: { message: "Failed to update submission" }, status: 500
      end
    else
      render json: { message: "Submission not found" }, status: 404
    end
  end

  private

  def submission_params
    params.require(:submission).permit(:assignment_id, :text_comment_draft)
  end
end
