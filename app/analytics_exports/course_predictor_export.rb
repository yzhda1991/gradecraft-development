class CoursePredictorExport
  include ::Analytics::Export::Model

  attr_accessor :users, :assignments

  rows_by :events

  set_schema username: :username,
             role: :user_role,
             user_id: :user_id,
             assignment: :assignment_name,
             assignment_id: :assignment_id,
             prediction: :predicted_points,
             possible: :possible_points,
             date_time: lambda { |event| event.created_at.to_formatted_s(:db) }

  def initialize(context:)
    @context = context
    @users = context[:active_record][:users]
    @assignments = context[:active_record][:assignments]
  end

  # filter the given events so that only predictor events are exported
  def filter(events)
    events.select {|event| event.event_type == "predictor" }
  end

  def username(event)
    return nil unless user_id = event.try(:user_id)
    usernames[user_id] || "[user id: #{event.user_id}]"
  end

  def assignment_name(event)
    return "[assignment id: nil]" unless event.respond_to? :assignment_id
    assignment_id = event.assignment_id.to_i
    assignment_names[assignment_id] || "[assignment id: #{assignment_id}]"
  end

  # since these filtering mechanisms for pulling usernames out of users
  # and assignment_names out of assignments are being used in multiple exports,
  # I wonder whether these should also be extracted into some kind of export
  # presenter helper module so we can keep all of this logic in one place.
  #

  # build an array or the given records in the format of
  # { user_id => "some_username" }
  def usernames
    @usernames ||= users.inject({}) do |hash, user|
      hash[user.id] = user.username
      hash
    end
  end

  # build an array or the given records in the format of
  # { assignment_id => "some_assignment_name" }
  def assignment_names
    @assignment_names ||= assignments.inject({}) do |hash, assignment|
      hash[assignment.id] = assignment.name
      hash
    end
  end
end
