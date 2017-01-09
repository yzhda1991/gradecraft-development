json.data do
  json.type "rubrics"
  json.id   @rubric.id.to_s

  json.attributes do
    json.id                         @rubric.id
    json.assignment_id              @rubric.assignment_id
  end

  json.relationships do
    json.criteria do
      json.data @criteria do |criterion|
          json.type "criteria"
          json.id criterion.id.to_s
      end
    end
  end
end

json.included do
  json.array! @criteria do |criterion|
    json.type "criteria"
    json.id   criterion.id.to_s

    json.attributes do
      json.merge! criterion.attributes

      json.levels criterion.levels do |level|
        json.id level.id
        json.name level.name
        json.description level.description
        json.points level.points
        json.full_credit !!level.full_credit
        json.no_credit !!level.no_credit
        json.meets_expectations level.meets_expectations
        # TODO: change Angular to handle array of badge ids: [1,2,5] and refactor
        json.level_badges level.level_badges do |level_badge|
          json.id level_badge.id
          json.level_id level_badge.level_id
          json.badge_id level_badge.badge_id
        end
      end
    end
  end
end


