class CourseMembership < ActiveRecord::Base
  belongs_to :course, touch: true
  belongs_to :user, touch: true

  # adds logging helpers for rescued-out errors
  include ModelAddons::ImprovedLogging

  attr_accessible :auditing, :character_profile, :course, :course_id, :instructor_of_record, :user, :user_id, :role

  Role.all.each do |role|
    scope role.pluralize, ->(course) { where role: role }
    define_method("#{role}?") do
      self.role == role
    end
  end

  scope :auditing, -> { where( :auditing => true ) }
  scope :being_graded, -> { where( :auditing => false) }

  validates :instructor_of_record, instructor_of_record: true

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
        self.update_attribute(:instructor_of_record, false)
      end
    end
  end

  def recalculate_and_update_student_score
    update_attribute :score, recalculated_student_score
  end

  def recalculated_student_score
    assignment_type_totals_for_student +
    student_earned_badge_score +
    conditional_student_team_score
  end

  def recalculation_test
    non_matching_sets = non_matching_test_score_sets
    puts "Total score sets: #{recalculation_test_score_sets.count}"
    puts "Total non-matching score sets: #{non_matching_sets.count}"
    puts "Listed non-matching sets:"
    non_matching_sets.each do |nms|
      puts nms
    end
    puts "No non-matching sets. All score recalculations matched the original scores." if non_matching_sets.empty?
  end

  def recalculation_test_score_sets
    @recalculation_test_score_sets ||= CourseMembership.all.collect do |cm|
      { 
        current_score: cm.score,
        recalculated_score: cm.recalculated_student_score,
        course_membership_id: cm.id,
        student_id: cm.user_id,
        course_id: cm.course_id
      }
    end
  end

  def non_matching_test_score_sets
    @non_matching_test_score_sets ||= recalculation_test_score_sets.select do |set|
      set[:current_score] != set[:recalculated_score]
    end
  end

  private

  def assignment_type_totals_for_student
    begin
      course.assignment_types.collect do |assignment_type|
        assignment_type.visible_score_for_student(user)
      end.compact.sum || 0
    rescue
      log_error_with_attributes("CourseMembership#assignment_type_totals_for_student was rescued to 0")
      0
    end
  end

  def student_earned_badge_score
    begin
      user.earned_badge_score_for_course(course_id) || 0
    rescue
      log_error_with_attributes("CourseMembership#student_earned_badge_score was rescued to 0")
      0
    end
  end

  def conditional_student_team_score
    include_team_score? ? student_team_score : 0
  end

  def student_team_score
    begin
      user.team_for_course(course_id).try(:score) || 0
    rescue
      log_error_with_attributes("CourseMembership#student_team_score was rescued to 0")
      0
    end
  end

  def include_team_score?
    course.add_team_score_to_student? and not course.team_score_average
  end

  public

  def staff?
    professor? || gsi? || admin?
  end

  protected

  def student_id
    @student_id ||= user.id
  end
end
