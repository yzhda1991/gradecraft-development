require_relative "presenter"

module Submissions
  class NewPresenter < Submissions::Presenter
    def submission
      @submission ||= properties[:submission] || assignment.submissions.new
    end

    def student
      properties[:student] || view_context.current_student
    end

    def title
      "Submit #{assignment.name} (#{view_context.points assignment.full_points} #{"point".pluralize(assignment.full_points)})"
    end

    def submission_will_be_late?
      assignment.due_at.present? && assignment.due_at < DateTime.now
    end
  end
end
