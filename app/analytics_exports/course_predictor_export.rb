class CoursePredictorExport
  include ::Analytics::Export::Model

  attr_accessor :users, :assignments

  export_mapping username: :username,
                 role: :user_role,
                 user_id: :user_id,
                 assignment: :assignment_name,
                 assignment_id: :assignment_id,
                 prediction: :predicted_points,
                 possible: :possible_points,
                 date_time: lambda { |event| event.created_at.to_formatted_s(:db) }

  def initialize(context:)
    # this is all of the export data that we've queried for already
    @context = context

    # these are the records that we're going to include in the export, which
    # in this case is all of the mongo events with an event_type of "predictor"
    # that also match the course_id that we used to fetch the various
    # collections in context.
    #
    @export_records = context[:mongoid][:predictor_events]

    # these are the additional records we queried from ActiveRecord to use for
    # adding context and data to our export columns related to assignments
    # and users
    #
    @users = context[:active_record][:users]
    @assignments = context[:active_record][:assignments]
  end


  # these are the methods being used to filter the 'row' values for the final
  # export CSV. There's probably a better way to organize them, but for now
  # let's at least keep them together and keep them commented.
  #
  # These correspond to the values in the export_mapping hash defined on the
  # class at the top of this file
  #
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
