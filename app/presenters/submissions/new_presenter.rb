require_relative "presenter"

module Submissions
  class NewPresenter < Submissions::Presenter
    def submission
      @submission ||= properties[:submission] || assignment.submissions.new
    end

    def student
      properties[:student] || view_context.current_student
    end
  end
end
