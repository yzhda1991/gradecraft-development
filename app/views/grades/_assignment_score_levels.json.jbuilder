json.array! assignment_score_levels do |score_level|
  json.(score_level, :id, :name, :points, :assignment_id)
end
