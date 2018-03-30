json.data do
  json.partial! 'api/assignment_types/assignment_type', assignment_type: @assignment_type, student: nil
end
