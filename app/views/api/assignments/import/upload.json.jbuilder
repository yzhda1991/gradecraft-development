json.data @assignment_rows do |row|
  json.type                               "assignment_row"

  json.attributes do
    json.assignment_name                  row.assignment_name
    json.assignment_type                  row.assignment_type
    json.point_total                      row.point_total
    json.description                      row.description
    json.due_date                         row.due_date
  end
end
