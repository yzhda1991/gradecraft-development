json.data @criterion_grades do |criterion_grade|
  json.partial! 'api/criterion_grades/criterion_grade', criterion_grade: criterion_grade
end



