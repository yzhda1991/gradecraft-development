require_relative "show_presenter"

module Submissions
  class EditPresenter < Submissions::ShowPresenter
    def submission
      properties[:submission] || super
    end
  end
end
