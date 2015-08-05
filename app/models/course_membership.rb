class CourseMembership < ActiveRecord::Base
  belongs_to :course
  belongs_to :user

  attr_accessible :auditing, :character_profile, :course_id, :user_id, :role

  ROLES = %w(student professor gsi admin)

  ROLES.each do |role|
    scope role.pluralize, ->(course) { where role: role }
  end

  scope :auditing, -> { where( :auditing => true ) }
  scope :being_graded, -> { where( :auditing => false) }

  def assign_role_from_lti(auth_hash)
    return unless auth_hash['extra'] && auth_hash['extra']['raw_info'] && auth_hash['extra']['raw_info']['roles']

    auth_hash['extra']['raw_info'].tap do |extra|

      case extra['roles'].downcase
      when /instructor/
        self.update_attribute(:role, 'professor')
      when /teachingassistant/
        self.update_attribute(:role, 'gsi')
      else
        self.update_attribute(:role, 'student')
      end
    end
  end

  protected
  def student_id
    @student_id ||= user.id
  end
end
