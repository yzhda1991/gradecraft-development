json.type "grade_scheme_elements"
json.id element.id.to_s

json.attributes do
  json.merge! element.attributes
  json.name element.name
end
