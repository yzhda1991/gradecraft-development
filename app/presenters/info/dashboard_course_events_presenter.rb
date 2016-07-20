require "./lib/showtime"

class Info::DashboardCourseEventsPresenter < Showtime::Presenter
  include Showtime::ViewContext

  def course
    properties[:course]
  end

  def student
    properties[:student]
  end

  def assignments
    properties[:assignments]
  end

  # figure out what dates need to be shown
  def dates_for(event)
    if event.open_at && event.due_at?
      "#{event.open_at} - #{event.due_at}"
    elsif event.due_at?
      "Due: #{event.due_at}"
    end
  end

  # collect the assignments that are on the same date as the event
  def assignments_due_on(event)
    assignments.where('DATE(due_at) = ?', event.due_at.to_date)
  end
end
