json.data @grade_files do |grade_file|
  json.type "grade_files"
  json.id grade_file.id.to_s

  json.attributes do
    json.merge! grade_file.attributes
  end
end
