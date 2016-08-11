class CoursePredictorExport < Analytics::Export::Model

  attr_accessor :users, :assignments

  column_mapping username: :username,
                 role: :user_role,
                 user_id: :user_id,
                 assignment: :assignment_name,
                 assignment_id: :assignment_id,
                 prediction: :predicted_points,
                 possible: :possible_points,
                 date_time: :formatted_event_timestamp

  def initialize(context:)
    @context = context

    # the subject of this export are the predictor events
    @export_records = context.predictor_events
  end

  # since these filtering mechanisms for pulling usernames out of users
  # and assignment_names out of assignments are being used in multiple exports,
  # I wonder whether these should also be extracted into some kind of export
  # presenter helper module so we can keep all of this logic in one place.

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
