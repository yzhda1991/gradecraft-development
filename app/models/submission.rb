class Submission < ActiveRecord::Base
  attr_accessible :task, :task_id, :assignment, :assignment_id, :assignment_type_id,
    :group, :group_id, :link, :student, :student_id, :creator, :creator_id,
    :text_comment, :graded, :submission_file, :submission_files_attributes, :submission_files,
    :course_id, :submission_file_ids, :updated_at

  include Canable::Ables
  include Historical
  include MultipleFileAttributes

  belongs_to :task, touch: true
  belongs_to :assignment, touch: true
  belongs_to :student, :class_name => 'User', touch: true
  belongs_to :creator, :class_name => 'User', touch: true
  belongs_to :group, touch: true
  belongs_to :course, touch: true

  before_save :clean_html, :submit_something
  after_save :check_unlockables

  has_one :grade
  has_one :assignment_weight, through: :assignment
  has_many :criterion_grades, dependent: :destroy

  accepts_nested_attributes_for :grade
  has_many :submission_files, :dependent => :destroy, autosave: true
  accepts_nested_attributes_for :submission_files

  scope :ungraded, -> { where('NOT EXISTS(SELECT 1 FROM grades WHERE submission_id = submissions.id OR (assignment_id = submissions.assignment_id AND student_id = submissions.student_id) AND (status = ? OR status = ?))', "Graded", "Released") }
  scope :graded, -> { where(:grade) }
  scope :resubmitted, -> { where('EXISTS(SELECT 1 FROM grades WHERE (assignment_id = submissions.assignment_id AND student_id = submissions.student_id) AND (updated_at < submissions.updated_at) AND (status = ? OR status = ?))', "Graded", "Released") }
  scope :date_submitted, -> { order('created_at ASC') }
  scope :for_course, ->(course) { where(course_id: course.id) }
  scope :for_student, ->(student) { where(student_id: student.id) }

  before_validation :cache_associations

  validates_uniqueness_of :task, :scope => :student, :allow_nil => true
  validates :link, :format => URI::regexp(%w(http https)) , :allow_blank => true
  validates :assignment, presence: true

  multiple_files :submission_files

  #Canable permissions#
  def updatable_by?(user)
    permissions_check(user)
  end

  def destroyable_by?(user)
    permissions_check(user)
  end

  #Permissions regarding who can see a grade
  def viewable_by?(user)
    permissions_check(user)
  end

  def graded_at
    grade.updated_at if graded?
  end

  def graded?
    !ungraded?
  end

  # Grabbing any submission that has NO instructor-defined grade (if the student has predicted the grade,
  # it'll exist, but we still don't want to catch those here)
  def ungraded?
    ! grade || grade.status == nil
  end

  def will_be_resubmission?
    Resubmission.future_resubmission?(self)
  end

  def resubmitted?
    !resubmissions.empty?
  end

  def resubmissions
    @resubmissions ||= Resubmission.find_for_submission(self)
  end

  # Getting the name of the student who submitted the work
  def name
    student.name
  end

  # Checking to see if a submission was turned in late
  def late?
    created_at > self.assignment.due_at if self.assignment.due_at.present?
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
      unlock_conditions = UnlockCondition.where(:condition_id => self.assignment.id, :condition_type => "Assignment").each do |condition|
        unlockable = condition.unlockable
        unlockable.check_unlock_status(student)
      end
    end
  end

  private

  def permissions_check(user)
    return true if user.is_staff?(course)
    if assignment.is_individual?
      student_id == user.id
    elsif assignment.has_groups?
      group_id == user.group_for_assignment(assignment).id
    end
  end

  def clean_html
    self.text_comment = Sanitize.clean(text_comment, Sanitize::Config::RESTRICTED)
  end

  def submit_something
    link.present? || text_comment.present? || submission_files.present?
  end

  def cache_associations
    if task
      self.assignment_id ||= task.assignment_id
      self.assignment_type ||= task.assignment_type
      self.course_id ||= task.assignment.course_id
    end
    self.assignment_id ||= assignment.id
    self.assignment_type ||= assignment.assignment_type
    self.course_id ||= assignment.course_id
  end
end
