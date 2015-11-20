class Assignment < ActiveRecord::Base
  include UploadsMedia
  include UploadsThumbnails
  include UnlockableCondition

  attr_accessible :name, :assignment_type_id, :assignment_type, :description,
    :point_total, :open_at, :due_at, :accepts_submissions_until,
    :release_necessary, :student_logged, :accepts_submissions, :accepts_links,
    :accepts_text, :accepts_attachments, :resubmissions_allowed, :grade_scope,
    :visible, :visible_when_locked, :required, :pass_fail, :use_rubric,
    :hide_analytics, :points_predictor_display, :notify_released,
    :mass_grade_type, :include_in_timeline, :include_in_predictor,
    :include_in_to_do, :grades_attributes, :assignment_file_ids,
    :assignment_files_attributes, :assignment_file,
    :assignment_score_levels_attributes, :assignment_score_level, :course

  attr_accessor :current_student_grade

  belongs_to :course, touch: true
  belongs_to :assignment_type, -> { order('position ASC') }, touch: true

  has_one :rubric, dependent: :destroy

  # For instances where the assignment needs its own unique score levels
  has_many :assignment_score_levels, -> { order "value" }, :dependent => :destroy
  accepts_nested_attributes_for :assignment_score_levels, allow_destroy: true,
    reject_if: proc { |a| a['value'].blank? || a['name'].blank? }

  # This is the assignment weighting system (students decide how much assignments will be worth for them)
  has_many :weights, class_name: "AssignmentWeight", dependent: :destroy

  # Student created groups, can connect to multiple assignments and receive group level or individualized feedback
  has_many :assignment_groups, :dependent => :destroy
  has_many :groups, :through => :assignment_groups

  # Multipart assignments
  has_many :tasks, :as => :assignment, :dependent => :destroy

  # Student created submissions to be graded
  has_many :submissions, :dependent => :destroy

  has_many :rubric_grades, :dependent => :destroy

  has_many :grades, :dependent => :destroy
  accepts_nested_attributes_for :grades,
    reject_if: proc { |attrs| attrs[:raw_score].blank? }

  # Instructor uploaded resource files
  has_many :assignment_files, dependent: :destroy
  accepts_nested_attributes_for :assignment_files

  # Preventing malicious content from being submitted
  before_save :sanitize_description

  # Strip points from pass/fail assignments
  before_save :zero_points_for_pass_fail

  # Check to make sure the assignment has a name before saving
  validates :course_id, presence: true
  validates_presence_of :name
  validates_presence_of :assignment_type_id
  validate :open_before_close, :submissions_after_due, :submissions_after_open

  scope :group_assignments, -> { where grade_scope: "Group" }

  # Filtering Assignments by where in the interface they are displayed
  scope :timelineable, -> { where(:include_in_timeline => true) }

  # Sorting assignments by different properties
  scope :chronological, -> { order('due_at ASC') }
  scope :alphabetical, -> { order('name ASC') }
  acts_as_list scope: :assignment_type

  # Filtering Assignments by various date properties
  scope :with_dates, -> { where('assignments.due_at IS NOT NULL OR assignments.open_at IS NOT NULL') }

  # Assignments and Grading
  scope :weighted_for_student, ->(student) { joins("LEFT OUTER JOIN assignment_weights ON assignments.id = assignment_weights.assignment_id AND assignment_weights.student_id = '#{sanitize student.id}'") }

  default_scope { order('position ASC') }

  delegate :student_weightable?, to: :assignment_type

  def copy
    copy = self.dup
    copy.name.prepend "Copy of "
    copy.save unless self.new_record?
    copy.assignment_score_levels << self.assignment_score_levels.map(&:copy)
    copy.rubric = self.rubric.copy if self.rubric.present?
    copy
  end

  def to_json(options = {})
    super(options.merge(only: [:id]))
  end

  def point_total
    super.presence || 0
  end

  def self.point_total_for_student(student)
    weighted_for_student(student).pluck('SUM(COALESCE(assignment_weights.point_total, self.course.total_points))').first || 0
  end

  # Used for calculating scores in the analytics tab in Assignments# show
  def grades_for_assignment(student)
    user_score = grades.where(:student_id => student.id).first.try(:raw_score)
    scores = grades.graded_or_released.pluck('raw_score')
    return {
    :scores => scores,
    :user_score => user_score
   }
  end

  def all_grades_for_assignment
    scores = grades.graded_or_released.pluck('raw_score')
    return {
    :scores => scores
   }
  end

  # Basic result stats - high, low, average, median
  def high_score
    grades.graded_or_released.maximum('grades.raw_score')
  end

  def low_score
    grades.graded_or_released.minimum('grades.raw_score')
  end

  # Average of all grades for an assignment
  def average
    grades.graded_or_released.average('grades.raw_score').to_i if grades.graded_or_released.present?
  end

  # Average of above-zero grades for an assignment
  def earned_average
    if grades.graded_or_released.present?
      grades.graded_or_released.where("score > 0").average('score').to_i
    else
      0
    end
  end

  def median
    sorted_grades = grades.graded_or_released.pluck('score').sort
    len = sorted_grades.length
    return (sorted_grades[(len - 1) / 2] + sorted_grades[len / 2]) / 2
  end

  def has_rubric?
    !! rubric
  end

  def fetch_or_create_rubric
    return rubric if rubric
    Rubric.create assignment_id: self[:id]
  end

  # Checking to see if an assignment is individually graded
  def is_individual?
    !['Group'].include? grade_scope
  end

  # Checking to see if the assignment is a group assignment
  def has_groups?
    grade_scope=="Group"
  end

  def is_predicted_by_student?(student)
    grade = grades.where(student_id: student.id).first
    !grade.nil? && grade.predicted_score > 0
  end

  # Custom point total if the class has weighted assignments
  def point_total_for_student(student, weight = nil)
    (point_total * weight_for_student(student, weight)).round rescue 0
    # rescue methods with a '0' for pass/fail assignments that are also student weightable for some untold reason
  end

  # Grabbing a student's set weight for the assignment - returns one if the course doesn't have weights
  def weight_for_student(student, weight = nil)
    return 1 unless student_weightable?
    weight ||= (weights.where(student: student).pluck('weight').first || 0)
    weight > 0 ? weight : default_weight
  end

  # Allows instructors to set a value (presumably less than 1) that would be multiplied by *not* weighted assignments
  def default_weight
    course.default_assignment_weight
  end

  # Getting a student's grade object for an assignment
  def grade_for_student(student)
    grades.graded_or_released.where(student_id: student.id).first
  end

  # Get a grade object for a student if it exists - graded or not. this is used in the import grade
  def all_grade_statuses_grade_for_student(student)
    grades.where(student_id: student).first
  end

  # Checking to see if an assignment is due soon
  def soon?
    future? && due_at < 7.days.from_now
  end

  # Setting the grade predictor displays
  def fixed?
    points_predictor_display == "Fixed"
  end

  def slider?
    points_predictor_display == "Slider"
  end

  def select?
    points_predictor_display == "Select List"
  end

  # The below four are the Quick Grading Types, can be set at either the assignment or assignment type level
  def grade_checkboxes?
    mass_grade_type == "Checkbox"
  end

  def grade_select?
    mass_grade_type == "Select List" && has_levels?
  end

  def grade_radio?
    mass_grade_type == "Radio Buttons" && has_levels?
  end

  def grade_text?
    mass_grade_type == "Text"
  end

  def has_levels?
    assignment_score_levels.present?
  end

  # Finding what grade level was earned for a particular assignment
  def grade_level(grade)
    assignment_score_levels.find { |asl| grade.raw_score == asl.value }.try(:name)
  end

  def future?
    !due_at.nil? && due_at >= Time.now
  end

  def opened?
    open_at.nil? || open_at < Time.now
  end

  def overdue?
    !due_at.nil? && due_at < Time.now
  end

  def accepting_submissions?
    accepts_submissions_until.nil? || accepts_submissions_until > Time.now
  end

  # Checking to see if the assignment is still open and accepting submissons
  def open?
    opened? && (!overdue? || accepting_submissions?)
  end

  # Counting how many grades there are for an assignment
  def grade_count
    grades.graded_or_released.count
  end

  # Calculating attendance rate, which tallies number of people who have positive grades for attendance divided by the total number of students in the class
  def completion_rate(course)
    return 0 if course.graded_student_count.zero?
   ((grade_count / course.graded_student_count.to_f) * 100).round(2)
  end

  # Counting the percentage of submissions from the entire class
  def submission_rate(course)
    return 0 if course.graded_student_count.zero?
    ((submissions.count / course.graded_student_count.to_f) * 100).round(2)
  end

  def predicted_count
    grades.predicted_to_be_done.count
  end

  # Calculating how many of each score exists
  def earned_score_count
    grades.graded_or_released
      .group_by { |g| g.raw_score }
      .map { |score, grade| [score, grade.size ] }.to_h
  end

  # Creating an array with the set of scores earned on the assignment, and
  def percentage_score_earned
    { scores: earned_score_count.collect { |s| { data: s[1], name: s[0] }}}
  end

  private

  def open_before_close
    if (due_at.present? && open_at.present?) && (due_at < open_at)
      errors.add :base, 'Due date must be after open date.'
    end
  end

  def submissions_after_due
    if (accepts_submissions_until.present? && due_at.present?) && (accepts_submissions_until < due_at)
      errors.add :base, 'Submission accept date must be after due date.'
    end
  end

  def submissions_after_open
    if (accepts_submissions_until.present? && open_at.present?) && (accepts_submissions_until < open_at)
      errors.add :base, 'Submission accept date must be after open date.'
    end
  end

  # Stripping the description of extra code
  def sanitize_description
    self.description = Sanitize.clean(description, Sanitize::Config::BASIC)
  end

  def zero_points_for_pass_fail
    self.point_total = 0 if self.pass_fail?
  end
end
