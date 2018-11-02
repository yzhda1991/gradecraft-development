class Submission < ApplicationRecord
  include Historical
  include MultipleFileAttributes
  include Sanitizable
  include AutoAwardOnUnlock

  has_paper_trail ignore: [:text_comment_draft]

  belongs_to :assignment
  belongs_to :student, class_name: "User"
  belongs_to :group
  belongs_to :course, touch: true

  after_save :check_unlockables

  has_one :grade

  accepts_nested_attributes_for :grade
  has_many :submission_files,
    dependent: :destroy,
    autosave: true,
    inverse_of: :submission
  accepts_nested_attributes_for :submission_files

  scope :with_grade, -> do
    joins("INNER JOIN grades ON "\
      "grades.assignment_id = submissions.assignment_id AND "\
      "(grades.group_id = submissions.group_id OR "\
      "grades.student_id = submissions.student_id)")
  end

  scope :by_active_individual_students, -> do
    individual
      .includes(student: :course_memberships)
      .where(student: { course_memberships: { active: true }})
  end

  scope :ungraded, -> do
    includes(:assignment, :group, :student)
    .where.not(id: with_grade.where(grades: { instructor_modified: true }))
  end

  scope :resubmitted, -> {
    includes(:grade, :assignment)
    .where("grades.student_visible = true")
    .where("grades.graded_at < submitted_at")
    .references(:grade, :assignment)
  }

  scope :order_by_submitted, -> { order("submitted_at ASC") }
  scope :for_course, ->(course) { where(course_id: course.id) }
  scope :for_student, ->(student_ids) { where(student_id: student_ids) }
  scope :for_assignment, -> (assignment_ids) { where(assignment_id: assignment_ids) }
  scope :for_assignment_and_student, ->(assignment_id, student_id) { where(assignment_id: assignment_id, student_id: student_id) }
  scope :for_assignment_and_group, ->(assignment_id, group_id) { where(assignment_id: assignment_id, group_id: group_id) }
  scope :submitted, -> { where.not(submitted_at: nil) }
  scope :with_group, -> { where "group_id is not null" }
  scope :individual, -> { where(group_id: nil) }

  before_validation :cache_associations

  validate :student_xor_group
  validates :link, format: URI::regexp(%w(http https)), allow_blank: true
  validates_length_of :link, maximum: 255
  validates :assignment, presence: true, uniqueness: { scope: [:student, :group],
    message: "should only have one submission per student or group" }, allow_nil: true
  validates_with SubmissionValidator

  clean_html :text_comment
  multiple_files :submission_files

  def self.by_active_grouped_students(submissions)
    submissions
      .where.not(group_id: nil)
      .select { |s| s.group.students.flat_map(&:course_memberships).any? { |cm| cm.active? && cm.course_id == s.course_id } }
  end

  def self.submitted_this_week(assignment_type)
    assignment_type.submissions.submitted.where("submissions.submitted_at > ? ", 7.days.ago)
  end

  def graded_at
    submission_grade.graded_at if submission_grade
  end

  # true for any submission that has an instructor modified grade
  def has_grade?
    !ungraded?
  end

  def submission_grade
    if assignment.has_groups?
      group.grade_for_assignment assignment if group.present?
    else
      student.grade_for_assignment assignment if student.present?
    end
  end

  # true for any submission that has NO instructor modified grade
  def ungraded?
    !submission_grade || !submission_grade.instructor_modified?
  end

  # Reports to the user that a change will be a resubmission because this
  # submission is already graded and visible to them.
  def will_be_resubmitted?
    return false unless submission_grade.present? && submission_grade.student_visible?
    return true
  end

  # this is transitive so that once it is graded again, then
  # it will no longer be resubmitted
  def resubmitted?
    submission_grade && submission_grade.student_visible? &&
    !graded_at.nil? && !submitted_at.nil? && graded_at < submitted_at
  end

  # Getting the name of the student who submitted the work
  def name
    student.name
  end

  def submitter
    assignment.has_groups? ? group : student
  end

  def submitter_id
    assignment.has_groups? ? group_id : student_id
  end

  # Checking to see if a submission was turned in late
  # Set while skipping validations and callbacks
  def check_and_set_late_status!
    return false if self.assignment.due_at.nil?
    self.update_column(:late, self.submitted_at.strftime("%Y-%m-%d %H:%M") > self.assignment.due_at.strftime("%Y-%m-%d %H:%M"))
  end

  # build a sensible base filename for all files that are attached to this submission
  def base_filename
    owner = student || group
    [owner.name, assignment.name].collect do |part|
      Formatter::Filename.titleize part
    end.compact.join " - "
  end

  def has_multiple_components?
    count = 0
    count += submission_files.count
    if link.present?
      count += 1
    end
    if text_comment.present?
      count +=1
    end
    return true if count > 1
    false
  end

  def check_unlockables
    if self.assignment.is_a_condition?
      unlock_conditions = UnlockCondition.where(condition_id: self.assignment.id, condition_type: "Assignment").each do |condition|
        unlockable = condition.unlockable
        if self.assignment.has_groups?
          self.group.students.each do |student|
            unlockable.unlock!(student) do |unlock_state|
              check_for_auto_awarded_badge(unlock_state)
              send_email_on_unlock
            end
          end
        else
          unlockable.unlock!(student) { |unlock_state| check_for_auto_awarded_badge(unlock_state) }
        end
      end
    end
  end

  def process_unconfirmed_files
    submission_files.unconfirmed.each do |submission_file|
      submission_file.check_and_set_confirmed_status
    end
  end

  def confirm_all_files
    submission_files.each do |submission_file|
      submission_file.check_and_set_confirmed_status
    end
  end

  def unsubmitted?
    submitted_at.nil?
  end

  def belongs_to?(user)
    if assignment.is_individual?
      student_id == user.id
    else
      user.group_memberships.pluck(:group_id).include? group_id
    end
  end

  def term_for_edit(user_is_staff)
    if !user_is_staff && text_comment_draft.present?
      "Edit Draft"
    elsif will_be_resubmitted?
      "Resubmit"
    else
      "Edit Submission"
    end
  end

  private

  def cache_associations
    self.assignment_id ||= assignment.id
    self.course_id ||= assignment.course_id
  end

  def student_xor_group
    errors.add(:base, "must have either a student_id or group_id, but not both") unless student.nil? ^ group.nil?
  end

  def check_for_auto_awarded_badge(unlock_state)
    award_badge(unlock_state, {
      student_id: student.id,
      course_id: course.id
    })
  end

  def send_email_on_unlock
    NotificationMailer.unlock_condition(self, student, course).deliver_now
  end
end
