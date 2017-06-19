assignment_types ||= current_course.assignment_types.all.select(:id, :name)

json.data @assignment_rows do |row|
  json.type                               "assignment_row"

  json.attributes do
    json.assignment_name                  row.assignment_name
    json.assignment_type                  row.assignment_type
    json.point_total                      row.point_total
    json.description                      row.description
    json.due_date                         row.due_date

    json.formatted_due_date               date_to_floating_point_seconds(row.due_date)
    json.selectedAssignmentType           parsed_assignment_type_id(assignment_types, row.assignment_type)
  end
end
