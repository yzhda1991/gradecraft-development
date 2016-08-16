require_relative "./context_filters/users_context_filter"
require_relative "./context_filters/assignments_context_filter"

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

  # filters add an extra layer of parsing on top of the base context queries
  #
  context_filters :users, :assignments

  # column parsing methods
  #
  def formatted_event_timestamp(event)
    # this is the equivalent of %Y-%m-%d %H:%M:%S
    event.created_at.strftime "%F %T"
  end

  def username(event)
    return nil unless user_id = event.try(:user_id)
    context_filters[:users].usernames[user_id] || "[user id: #{event.user_id}]"
  end

  def assignment_name(event)
    return "[assignment id: nil]" unless event.respond_to? :assignment_id
    assignment_id = event.assignment_id.to_i
    context_filters[:assignments].assignment_names[assignment_id] || "[assignment id: #{assignment_id}]"
  end
end
