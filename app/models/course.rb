require_relative "role"

class Course < ActiveRecord::Base
  include Copyable
  include UnlockableCondition

  after_create :create_admin_memberships

  # Note: we are setting the role scopes as instance methods,
  # not class methods, so that they are limited to the users
  # of the current course
  Role.all.each do |role|
    define_method(role.pluralize) do
      User.with_role_in_course(role, self)
    end
  end

  # Staff returns all professors and GSI for the course.
  # Note that this is different from is_staff? which currently
  # includes Admin users
  def staff
    User.with_role_in_course("staff", self)
  end

  def instructors_of_record
    InstructorsOfRecord.for(self).users
  end

  def instructors_of_record_ids
    instructors_of_record.map(&:id)
  end

  def instructors_of_record_ids=(value)
    user_ids = value.map(&:to_i)
    InstructorsOfRecord.for(self).update_course_memberships(user_ids)
  end

  def students_being_graded
    User.students_being_graded(self)
  end

  def students_being_graded_by_team(team)
    User.students_being_graded(self,team)
  end

  def students_by_team(team)
    User.students_by_team(self, team)
  end

  attr_accessible :course_number, :name,
    :semester, :year, :has_badges, :has_teams, :instructors_of_record_ids,
    :team_term, :student_term, :section_leader_term, :group_term, :lti_uid,
    :user_id, :course_id, :course_rules, :syllabus,
    :has_character_names, :has_team_roles, :has_character_profiles, :hide_analytics,
    :total_weights, :weights_close_at,
    :assignment_weight_type, :has_submissions, :teams_visible,
    :weight_term, :fail_term, :pass_term,
    :max_weights_per_assignment_type, :assignments,
    :accepts_submissions, :tagline, :office, :phone,
    :class_email, :twitter_handle, :twitter_hashtag, :location, :office_hours,
    :meeting_times, :assignment_term, :challenge_term, :badge_term, :gameful_philosophy,
    :team_score_average, :has_team_challenges, :team_leader_term,
    :max_assignment_types_weighted, :full_points, :has_in_team_leaderboards,
    :grade_scheme_elements_attributes, :add_team_score_to_student, :status,
    :assignments_attributes, :start_date, :end_date

  with_options dependent: :destroy do |c|
    c.has_many :student_academic_histories
    c.has_many :assignment_types
    c.has_many :assignments
    c.has_many :announcements
    c.has_many :badges
    c.has_many :challenges
    c.has_many :challenge_grades, through: :challenges
    c.has_many :earned_badges
    c.has_many :grade_scheme_elements, -> { extending GradeSchemeElementScoringExtension }
    c.has_many :grades
    c.has_many :groups
    c.has_many :group_memberships
    c.has_many :submissions
    c.has_many :teams
    c.has_many :course_memberships
    c.has_many :submissions_exports
    c.has_many :course_analytics_exports
    c.has_many :events
  end

  has_many :users, through: :course_memberships
  accepts_nested_attributes_for :users
  accepts_nested_attributes_for :assignments

  mount_uploader :syllabus, CourseSyllabusUploader

  accepts_nested_attributes_for :grade_scheme_elements, allow_destroy: true

  validates_presence_of :name, :course_number

  validates_numericality_of :total_weights, allow_blank: true
  validates_numericality_of :max_weights_per_assignment_type, allow_blank: true
  validates_numericality_of :max_assignment_types_weighted, allow_blank: true
  validates_numericality_of :full_points, allow_blank: true

  validates_format_of :twitter_hashtag, with: /\A[A-Za-z][A-Za-z0-9]*(?:_[A-Za-z0-9]+)*\z/, allow_blank: true, length: { within: 3..20 }

  scope :alphabetical, -> { order("course_number ASC") }
  scope :active, -> { where(status: true) }
  scope :inactive, -> { where.not(status: true) }

  def self.find_or_create_by_lti_auth_hash(auth_hash)
    criteria = { lti_uid: auth_hash["extra"]["raw_info"]["context_id"] }
    where(criteria).first || create!(criteria) do |c|
      c.lti_uid = auth_hash["extra"]["raw_info"]["context_id"]
      c.course_number = auth_hash["extra"]["raw_info"]["context_label"]
      c.name = auth_hash["extra"]["raw_info"]["context_title"]
      c.year = Date.today.year
    end
  end

  def copy(copy_type, attributes={})
    if copy_type != "with_students"
      copy_with_associations(attributes, [])
    else
      begin
        Course.skip_callback(:create, :after, :create_admin_memberships)
        copy_with_associations(attributes, [:course_memberships])
      ensure
        Course.set_callback(:create, :after, :create_admin_memberships)
      end
    end
  end

  def valuable_badges?
    badges.any? { |badge| badge.full_points.present? && badge.full_points > 0 }
  end

  def formatted_tagline
    if tagline.present?
      tagline
    else
      " "
    end
  end

  def formatted_short_name
    if semester.present? && year.present?
      "#{self.course_number} #{(self.semester).capitalize.first[0]}#{self.year}"
    else
      "#{course_number}"
    end
  end

  # total number of points 'available' in the course - sometimes set by an
  # instructor as a cap, sometimes just the sum of all assignments
  def total_points
    full_points || assignments.sum("full_points")
  end

  def active?
    status == true
  end

  def student_weighted?
    total_weights.to_i > 0
  end

  def assignment_weight_open?
    weights_close_at.nil? || weights_close_at > Time.now
  end

  def membership_for_student(student)
    course_memberships.detect { |m| m.user_id == student.id }
  end

  def assignment_weight_for_student(student)
    student.assignment_type_weights.where(course_id: self.id).pluck("weight").sum
  end

  def assignment_weight_spent_for_student(student)
    assignment_weight_for_student(student) >= total_weights.to_i
  end
  
  # Descriptive stats of the grades
  def minimum_course_score
    CourseMembership.where(course: self, auditing: false,
      role: "student").minimum("score")
  end

  def maximum_course_score
    CourseMembership.where(course: self, auditing: false,
      role: "student").maximum("score")
  end

  def average_course_score
    CourseMembership.where(course: self, auditing: false,
      role: "student").average("score").to_i
  end

  def student_count
    students.count
  end

  def graded_student_count
    students_being_graded.count
  end

  def groups_to_review_count
    groups.pending.count
  end

  def point_total_for_challenges
    challenges.pluck("full_points").sum
  end

  def recalculate_student_scores
    ordered_student_ids.each do |student_id|
      ScoreRecalculatorJob.new(user_id: student_id, course_id: self.id).enqueue
    end
  end

  def ordered_student_ids
    User
      .unscoped # clear the default scope
      .joins(:course_memberships)
      .where("course_memberships.course_id = ? and course_memberships.role = ?", self.id, "student")
      .select(:id) # only need the ids, please
      .order("id ASC")
      .collect(&:id)
  end

  # badges
  def course_badge_count
    badges.count
  end

  def awarded_course_badge_count
    earned_badges.count
  end

  # box plot for instructor dashboard
  def scores
    scores = CourseMembership.where(course: self, auditing: false,
      role: "student").pluck("score")
    return {
      scores: scores
    }
  end
  
  def earned_grade_scheme_elements_by_student_count
    elements = []
    grade_scheme_elements.each do |gse| 
      elements << [gse.name, gse.count_students_earned]
    end
    return { 
      elements: elements.reverse
    }
  end

  private

  def create_admin_memberships
    User.where(admin: true).each do |admin|
      CourseMembership.create course_id: self.id, user_id: admin.id, role: "admin"
    end
  end

  def copy_with_associations(attributes, associations)
    ModelCopier.new(self).copy(attributes: attributes,
                               associations: [
                                 :badges,
                                 { assignment_types: { course_id: :id }},
                                 :challenges,
                                 :grade_scheme_elements
                               ] + associations,
                               options: { prepend: { name: "Copy of " }})
  end
end
