require "./lib/showtime"

class AssignmentGroupPresenter < Showtime::Presenter
  def group
    properties[:group]
  end
end
