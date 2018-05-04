class API::GradingStatus::SubmissionsController < ApplicationController
  include SubmissionsHelper

  before_action :ensure_staff?
  before_action :find_submissions

  def ungraded
    @submissions = active_individual_and_group_submissions @submissions.ungraded
    render :"api/grading_status/submissions/index", status: 200
  end

  private

  def find_submissions
    @submissions = current_course
      .submissions
      .submitted
      .includes(:assignment, :grade, :student, :group, :submission_files)
  end
end
