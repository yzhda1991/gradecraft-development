class AssignmentExportsController < ApplicationController
  before_filter :fetch_assignment
  respond_to :json

  def submissions
    @submissions = @assignment.student_submissions
  end

  def submissions_by_team
    @team = Team.find params[:team_id]
    @submissions = @assignment.student_submissions_for_team(@team)
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

    def fetch_assignment
      @assignment ||= Assignment.find params[:assignment_id]
    end

end
