require_relative "show_presenter"

module Submissions
  class EditPresenter < Submissions::ShowPresenter
    def submission
      properties[:submission] || super
    end

    def title
      if view_context.current_user.is_student?(course)
        "Editing My Submission for #{assignment.name}"
      else
        name = assignment.has_groups? ? group.name : student.name
        "Editing #{name}'s Submission"
      end
    end
  end
end
