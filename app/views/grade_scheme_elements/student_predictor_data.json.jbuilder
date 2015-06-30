json.total_points current_course.total_points

json.grade_scheme_elements @grade_scheme_elements do |gse|
  json.merge! gse.attributes
end
