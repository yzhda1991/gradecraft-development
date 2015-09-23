class AssignmentExportsController < ApplicationController
  before_filter :ensure_staff?
  before_filter :fetch_assignment
  before_filter :fetch_team, only: :submissions_by_team

  respond_to :json

  def submissions
    render :submissions, submissions_presenter
  end

  def submissions_by_team
    render :submissions_by_team, submissions_by_team_presenter
  end

  def export
    fetch_assignment
    @submissions ||= @assignment.student_submissions
    group_submissions_by_student
  end

  private
    def group_submissions_by_student
      @submissions_by_student ||= @submissions.group_by do |submission|
        student = submission.student
        "#{student[:last_name]}_#{student[:first_name]}-#{student[:id]}".downcase
      end
    end

    def submissions_by_team_presenter
      @presenter ||= AssignmentExportPresenter.build({
        submissions: @assignment.student_submissions_for_team(@team),
        assignment: @assignment,
        team: @team
      })
    end

    def submissions_presenter
      @presenter ||= AssignmentExportPresenter.build({
        submissions: @assignment.student_submissions,
        assignment: @assignment
      })
    end

    def fetch_assignment
      @assignment = Assignment.find params[:assignment_id]
    end

    def fetch_team
      @team = Team.find params[:team_id]
    end
end
