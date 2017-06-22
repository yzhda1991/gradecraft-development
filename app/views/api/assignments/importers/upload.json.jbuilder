assignment_types ||= current_course.assignment_types.all.select(:id, :name)

json.data @assignment_rows do |row|
  assignment_type_id = parsed_assignment_type_id(assignment_types, row.assignment_type)

  json.type "assignment_row"

  json.attributes do
    json.assignment_name row.assignment_name
    json.assignment_type row.assignment_type
    json.point_total row.point_total
    json.description row.description
    json.due_date row.due_date

    json.formatted_due_date date_to_floating_point_seconds(row.due_date)
    json.selected_assignment_type assignment_type_id
    json.has_matching_assignment_id assignment_type_id.present?
  end
end
