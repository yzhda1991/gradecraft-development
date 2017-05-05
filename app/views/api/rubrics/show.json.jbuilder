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
        json.sort_order level.sort_order
        json.meets_expectations level.meets_expectations
        json.level_badges level.level_badges do |level_badge|
          json.id level_badge.id
          json.level_id level_badge.level_id
          json.badge_id level_badge.badge_id
        end
        # For performance, we determine available badges here rather than in Angular
        badge_ids = level.level_badges.pluck(:badge_id)
        json.available_badges current_course.badges do |badge|
          if !badge_ids.include?(badge.id)
            json.id badge.id
            json.name badge.name
          end
        end
      end
    end
  end
end

json.meta do
  json.full_points @rubric.assignment.full_points
end


