require "./lib/showtime"

class AssignmentGroupPresenter < Showtime::Presenter
  def group
    properties[:group]
  end

  def title
    "#{group.name} Grades"
  end
end
