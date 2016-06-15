json.set! :timeline do

  json.set! :headline, current_course.name
  json.set! :type, "default"

  json.set! :events do
    json.array! @events do |event|
      if event.open_at && event.due_at
        json.startDate event.open_at
        json.endDate event.due_at
      elsif event.open_at
        json.startDate event.open_at
        json.endDate event.open_at
      elsif event.due_at
        json.startDate event.due_at
        json.endDate event.due_at
      end
      json.headline event.name
    end
  end
end
