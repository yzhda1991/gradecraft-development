json.data @criterion_grades do |criterion_grade|
  json.type "criterion_grades"
  json.id criterion_grade.id.to_s

  json.attributes do
    json.merge! criterion_grade.attributes
  end
end
