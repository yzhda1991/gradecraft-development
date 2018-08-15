assignment_types ||= current_course.assignment_types.all.select(:id, :name)

json.data @assignment_rows do |row|
  assignment_type_id = parsed_assignment_type_id(assignment_types, row.assignment_type)

  json.type "assignment_row"

  json.attributes do
    json.name row.name
    json.assignment_type row.assignment_type
    json.full_points row.full_points
    json.description row.description
    json.purpose row.purpose
    json.open_at row.open_at
    json.due_at row.due_at
    json.accepts_submissions row.accepts_submissions
    json.accepts_submissions_until row.accepts_submissions_until
    json.required row.required

    json.formatted_open_at date_to_floating_point_seconds(row.open_at)
    json.formatted_due_at date_to_floating_point_seconds(row.due_at)
    json.formatted_accepts_submissions_until date_to_floating_point_seconds(row.accepts_submissions_until)
    json.selected_assignment_type assignment_type_id
    json.has_matching_assignment_type_id assignment_type_id.present?
  end
end
