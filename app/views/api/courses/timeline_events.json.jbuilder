json.set! :timeline do

  json.set! :date do
    json.array! @events do |event|
      if event.open_at && event.due_at
        json.startDate event.open_at.in_time_zone(current_user.time_zone)
        json.endDate event.due_at.in_time_zone(current_user.time_zone)
      elsif event.open_at
        json.startDate event.open_at.in_time_zone(current_user.time_zone)
        json.endDate event.open_at.in_time_zone(current_user.time_zone)
      elsif event.due_at
        json.startDate event.due_at.in_time_zone(current_user.time_zone)
        json.endDate event.due_at.in_time_zone(current_user.time_zone)
      end
      json.headline event.name
      json.text timeline_content(event)
      json.set! :asset do
        if event.media
          json.media event.media_url
        end
      end
    end
  end
end
