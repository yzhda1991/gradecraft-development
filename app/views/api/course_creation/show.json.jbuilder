json.data do
  json.type "course_creation"
  json.id   @course_creation.id.to_s

  json.attributes do
    json.id          @course_creation.id
    json.course_id   @course_creation.course_id

    json.checklist do
      json.array! @course_creation.checklist do |item|
        json.name item
        json.title @course_creation.title_for_item(item)
        json.done @course_creation[item]
      end
    end
  end
end

json.meta do
  json.term_for_assignments term_for :assignments
  json.term_for_teams term_for :teams
  json.term_for_badges term_for :badges
end

