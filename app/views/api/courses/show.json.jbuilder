json.data do
  json.id @course.id
  json.type "courses"

  json.attributes do
    json.id @course.id

    json.has_in_team_leaderboards @course.has_in_team_leaderboards?
    json.has_character_names @course.has_character_names?
    json.has_badges @course.has_badges?
    json.has_team_roles @course.has_team_roles?
    json.has_teams @course.has_teams?
  end

  json.relationships do
    json.grade_scheme_elements do
      json.data @course.grade_scheme_elements do |gse|
        json.type "grade_scheme_elements"
        json.id gse.id
      end
    end
  end
end

json.included do
  json.array! @course.grade_scheme_elements do |gse|
    json.id gse.id
    json.type "grade_scheme_elements"

    json.attributes do
      json.id gse.id
      json.name gse.name
    end
  end
end
