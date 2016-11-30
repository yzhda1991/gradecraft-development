class API::Assignments::SubmissionsController < ApplicationController
  before_action :ensure_student?

  def show
    assignment = Assignment.find(params[:assignment_id])
    submission = nil

    if assignment.is_individual?
      submission = Submission.for_assignment_and_student(assignment.id, current_user.id).first
    else
      submission = Submission.for_assignment_and_group(assignment.id, current_student.group_for_assignment(assignment).id).first
    end

    if submission.present?
      render json: { submission: submission, message: "Found an existing submission draft" }, status: 200
    else
      render json: { submission: Submission.new(assignment_id: params[:assignment_id]),
        message: "No existing submission draft was found" }, status: 404
    end
  end

  def create
    assignment = Assignment.find(params[:assignment_id])
    submission = assignment.submissions.new merged_submission_params(assignment)

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
