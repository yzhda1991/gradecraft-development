class UserProctor
  attr_reader :user

  def initialize(user)
    @user = user
  end

  def can_update_password?(proxy, course)
    return false if user.kerberos_uid.present? || !user.persisted?
    return true if proxy.is_admin? course
    return false unless proxy.is_professor? course
    Rails.env.beta? && course.institution.try(:institution_type) == "K-12"
  end

  def can_update_email?(proxy, course)
    return true if proxy.is_admin? course
    !Rails.env.production?
  end
end
