class CoursePredictorExport
  include ::Analytics::Export::Model

  attr_accessor :usernames, :assignment_names
  attr_reader :loaded_data

  rows_by :events

  set_schema username: :username,
             role: :user_role,
             user_id: :user_id,
             assignment: :assignment_name,
             assignment_id: :assignment_id,
             prediction: :predicted_points,
             possible: :possible_points,
             date_time: lambda { |event| event.created_at.to_formatted_s(:db) }

  def initialize(loaded_data)
    @loaded_data = loaded_data
    get_and_cache_usernames
    get_and_cache_assignment_names
  end

  def schema_records_for_role(role)
    schema_records records.select {|event| event.user_role == role }
  end

  def get_and_cache_usernames
    @usernames ||= loaded_data[:users].inject({}) do |hash, user|
      hash[user.id] = user.username
      hash
    end
  end

  def get_and_cache_assignment_names
    assignments = loaded_data[:assignments]
    @assignment_names ||= assignments.inject({}) do |hash, assignment|
      hash[assignment.id] = assignment.name
      hash
    end
  end

  def filter(events)
    events.select {|event| event.event_type == "predictor" }
  end

  def username(event, index)
    usernames[event.user_id] || "[user id: #{event.user_id}]"
  end

  def assignment_name(event, index)
    return "[assignment id: nil]" unless event.respond_to? :assignment_id
    assignment_id = event.assignment_id.to_i
    @assignment_names[assignment_id] || "[assignment id: #{assignment_id}]"
  end
end
