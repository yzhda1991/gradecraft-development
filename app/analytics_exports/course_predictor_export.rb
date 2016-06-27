class CoursePredictorExport
  include Analytics::Export::Model

  rows_by :events

  set_schema username: :username,
             role: :user_role,
             user_id: :user_id,
             assignment: :assignment_name,
             assignment_id: :assignment_id,
             prediction: :predicted_points,
             possible: :possible_points,
             date_time: lambda { |event| event.created_at.to_formatted_s(:db) }

  def schema_records_for_role(role)
    self.schema_records records.select {|event| event.user_role == role }
  end

  def initialize(loaded_data)
    @usernames = loaded_data[:users].inject({}) do |hash, user|
      hash[user.id] = user.username
      hash
    end
    @assignment_names =
      loaded_data[:assignments].inject({}) do |hash, assignment|
        hash[assignment.id] = assignment.name
        hash
      end
    super
  end

  def filter(events)
    events.select{ |event| event.event_type == "predictor" }
  end

  def username(event, index)
    @usernames[event.user_id] || "[user id: #{event.user_id}]"
  end

  def assignment_name(event, index)
    return "[assignment id: nil]" unless event.respond_to? :assignment_id
    assignment_id = event.assignment_id.to_i
    @assignment_names[assignment_id] || "[assignment id: #{assignment_id}]"
  end
end
