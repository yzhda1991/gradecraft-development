class CoursePredictorExport < Analytics::Export::Model

  # what is the base set of records we'd like to use from the context to
  # generate this export. These records will translate to rows on the final
  # export csv.
  #
  export_focus :predictor_events

  # map the column name to the attribute or method name on the record that we'd
  # like to use to populate each row
  #
  column_mapping username: :username,
                 role: :user_role,
                 user_id: :user_id,
                 assignment: :assignment_name,
                 assignment_id: :assignment_id,
                 prediction: :predicted_points,
                 possible: :possible_points,
                 date_time: :formatted_event_timestamp


  # filters for individual columns in the export
  #
  def formatted_event_timestamp(event)
    event.created_at.to_formatted_s :db
  end

  def username(event)
    return nil unless user_id = event.try(:user_id)
    context.usernames[user_id] || "[user id: #{event.user_id}]"
  end

  def assignment_name(event)
    return "[assignment id: nil]" unless event.respond_to? :assignment_id
    assignment_id = event.assignment_id.to_i
    context.assignment_names[assignment_id] || "[assignment id: #{assignment_id}]"
  end
end
