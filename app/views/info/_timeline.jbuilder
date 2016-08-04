json.set! :timeline do

  json.set! :headline, current_course.name
  json.set! :type, "default"
  json.set! :text, current_course.formatted_tagline

  json.set! :date do
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
      json.text timeline_content(event)
      json.set! :asset do
        if event.thumbnail && event.media
          json.thumbnail event.thumbnail_url
          json.media event.media_url
        elsif event.media
          json.media event.media_url
        elsif event.thumbnail
          json.thumbnail event.thumbnail_url
        end
        json.credit event.media_credit
        json.caption event.media_caption
      end
    end
  end
end
