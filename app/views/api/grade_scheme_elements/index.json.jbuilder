json.data @grade_scheme_elements do |gse|
  json.partial! 'api/grade_scheme_elements/element', element: gse

  if @student.present?
    json.is_locked gse.is_unlockable? && !gse.is_unlocked_for_student?(@student)
  end
end

json.meta do
  json.total_points @total_points
end
