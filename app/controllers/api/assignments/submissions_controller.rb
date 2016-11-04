class API::Assignments::SubmissionsController < ApplicationController
  before_action :ensure_student?

  def create
    assignment = Assignment.find(params[:assignment_id])
    submission = assignment.submissions.new submission_params.merge(student_id: current_user.id)

    if submission.save
      render json: { submission: submission, message: "Successsfully created a submission draft" }, status: 201
    else
      render json: { message: "Failed to create submission" }, status: 500
    end
  end

  def update
    assignment = Assignment.find_by(id: params[:assignment_id])
    submission = assignment.submissions.find_by(id: params[:id])

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
    params.require(:submission).permit(:text_comment)
  end
end
