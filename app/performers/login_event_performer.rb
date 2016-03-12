class LoginEventPerformer < ResqueJob::Performer
  attr_accessor :data, :user_id, :course_id, :course_membership

  # this is called on #initialize
  def setup
    @data = attrs[:data].is_a?(Hash) ? attrs[:data] : {}
    @course_membership = find_course_membership
    return unless course_membership # these methods require a course_membership
    cache_last_login_at
    update_course_membership_login
  end

  def perform
    require_success(messages) do
      # exit the block with false unless a user_role is present
      next false unless data[:user_role]
      # create a new analytics event with the data and check if it's valid
      Analytics::LoginEvent.create(data).valid?
    end
  end

  # pass the last_login_at time from the CourseMembership to the data hash
  def cache_last_login_at
    @data[:last_login_at] = course_membership.last_login_at.try(:to_i)
  end

  # set the new last_login_at time to whenever the login event was created
  def update_course_membership_login
    return false unless data[:created_at]
    course_membership.update_attributes last_login_at: data[:created_at]
  end

  def find_course_membership
    return unless course_membership_attrs.values.all?(&:present?)
    CourseMembership.find_by course_membership_attrs
  end

  def course_membership_attrs
    { user_id: data[:user_id], course_id: data[:course_id] }
  end

  def messages
    {
      success: "Successfully logged login event with data #{data}",
      failure: "Failed to log login event with data #{data}"
    }
  end
end
