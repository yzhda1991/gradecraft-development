require "./lib/showtime"

class SubmissionPresenter < Showtime::Presenter
  include Showtime::ViewContext

  def submission
    properties[:submission]
  end
end
