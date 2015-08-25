json.grade_scheme_elements @grade_scheme_elements do |gse|
  json.cache! ['v1', gse] do
    json.merge! gse.attributes
  end
end

json.total_points @total_points
