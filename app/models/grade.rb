class Grade < ActiveRecord::Base
  include GradeStatus
  include Historical
  include MultipleFileAttributes
  include Sanitizable

  attr_accessible :_destroy, :adjustment_points, :adjustment_points_feedback,
    :assignment, :assignment_id, :assignment_type_id, :assignments_attributes,
    :course_id, :earned_badges, :earned_badges_attributes, :excluded_by,
    :excluded_date, :excluded_from_course_score, :feedback, :feedback_read,
    :feedback_read_at, :feedback_reviewed, :feedback_reviewed_at, :final_points,
    :grade_file, :grade_file_ids, :grade_files_attributes, :graded_at,
    :graded_by_id, :group, :group_id, :group_type, :instructor_modified,
    :is_custom_value, :pass_fail_status, :full_points, :raw_points, :student,
    :student_id, :submission, :submission_id, :task, :task_id, :team_id, :status

  belongs_to :course, touch: true
  belongs_to :assignment, touch: true
  belongs_to :assignment_type, touch: true
  belongs_to :student, class_name: "User", touch: true
  belongs_to :team, touch: true
  belongs_to :submission
  belongs_to :task, touch: true # Optional
  belongs_to :group, polymorphic: true, touch: true # Optional
  belongs_to :graded_by, class_name: "User", touch: true

  has_many :earned_badges, dependent: :destroy

  has_many :badges, through: :earned_badges
  accepts_nested_attributes_for :earned_badges,
    reject_if: proc { |a| (a["score"].blank?) }, allow_destroy: true

  before_validation :cache_associations
  before_save :calculate_points
  before_save :zero_points_for_pass_fail
  after_save :check_unlockables

  clean_html :feedback
  multiple_files :grade_files
  releasable_through :assignment

  has_many :grade_files, dependent: :destroy
  accepts_nested_attributes_for :grade_files

  validates_presence_of :assignment, :assignment_type, :course, :student
  validates :assignment_id, uniqueness: { scope: :student_id }

  delegate :name, :description, :due_at, :assignment_type, :course, to: :assignment

  after_destroy :cache_student_and_team_scores

  scope :completion, -> { where(order: "assignments.due_at ASC", joins: :assignment) }
  scope :order_by_highest_score, -> { order("score DESC") }

  scope :excluded_from_course_score, -> { where excluded_from_course_score: true }
  scope :included_in_course_score, -> { where excluded_from_course_score: false }
  scope :no_status, -> { instructor_modified.where(status: ["", nil])}
  scope :instructor_modified, -> { where instructor_modified: true }
  scope :positive, -> { where("score > 0")}
  scope :for_course, ->(course) { where(course_id: course.id) }
  scope :for_student, ->(student) { where(student_id: student.id) }
  scope :not_nil, -> { where.not(score: nil)}

  def self.find_or_create(assignment_id,student_id)
    Grade.find_or_create_by(student_id: student_id, assignment_id: assignment_id)
  end

  def self.find_or_create_grades(assignment_id,student_ids)
    student_ids.each do |student_id|
      find_or_create(assignment_id, student_id)
    end
    Grade.where(student_id: student_ids, assignment_id: assignment_id)
  end

  def feedback_read!
    update_attributes feedback_read: true, feedback_read_at: DateTime.now
  end

  def feedback_reviewed!
    update_attributes feedback_reviewed: true, feedback_reviewed_at: DateTime.now
  end

  # Handle raw points attributes with commas (ex "300,000")
  def raw_points=(rp)
    if rp.class == String
      rp.delete!(",").to_i
    end
    write_attribute(:raw_points, rp)
  end

  def predicted_points
    PredictedEarnedGrade.where(
      student_id: self.student_id,
      assignment_id: self.assignment_id).first.try(:predicted_points) || 0
  end

  def assignment_weight
    assignment_type.weight_for_student(student)
  end

  def has_feedback?
    feedback.present?
  end

  # @mz TODO: add specs
  def cache_student_and_team_scores
    { cached_student_score: cache_student_score_and_level,
      cached_team_score: cache_team_score,
      student_id: self.student.try(:id),
      team_id: cached_student_team.try(:id)
    }.merge(cached_score_failure_information)
  end

  def check_unlockables
    if self.assignment.is_a_condition? 
      self.assignment.unlock_keys.map(&:unlockable).each do |unlockable|
        unlockable.check_unlock_status(student)
      end
    end
    if self.assignment_type.is_a_condition? 
      self.assignment_type.unlock_keys.map(&:unlockable).each do |unlockable|
        unlockable.check_unlock_status(student)
      end
    end  
  end

  def excluded_by
    User.find(excluded_by_id)
  end

  private

  # full points (with student's weighting)
  def calculate_full_points
    assignment.full_points_for_student(student)
  end

  # totaled points (adds adjustment, without weighting)
  def calculate_final_points
    return nil unless raw_points.present?
    final_points = raw_points + adjustment_points
    final_points >= assignment.threshold_points ? final_points : 0
  end

  # points with student's weighting
  def calculate_score
    return nil unless raw_points.present?
    weighting = assignment_type.student_weightable? ? assignment_weight : 1
    final_points * weighting
  end

  # Calculate all stored points fields before save
  def calculate_points
    self.full_points = calculate_full_points
    self.final_points = calculate_final_points
    self.score = calculate_score
  end

  def cache_associations
    self.student_id ||= submission.try(:student_id)
    self.task_id ||= submission.try(:task_id)
    self.assignment_id ||= submission.try(:assignment_id) || task.try(:assignment_id)
    self.assignment_type_id ||= assignment.try(:assignment_type_id)
    self.course_id ||= assignment.try(:course_id)
    # self.team_id ||= student.team_for_course(course).try(:id)
  end

  def zero_points_for_pass_fail
    if self.assignment.pass_fail?
      self.raw_points = 0
      self.final_points = 0
      self.full_points = 0
    end
  end

  def duplicate_badge_for_grade
    if self.earned_badges.where(badge_id: earned_badge.badge_id).persisted?
      errors.add("")
    end
  end

  def cached_student_team
    @team ||= student.team_for_course(course)
  end

  # @mz TODO: add specs
  def cache_student_score_and_level
    student.cache_course_score_and_level(self.course.id)
  end

  # @mz TODO: add specs, improve the syntax here
  def cache_team_score
    if course.has_teams? && student.team_for_course(course).present?
      @team = cached_student_team
      @team_update_successful = @team.update_revised_team_score
      @team_update_successful ? @team.score : false
    end
  end

  def cached_score_failure_information
    failure_attrs = {}
    if course.has_teams? && student.team_for_course(course).present?
      unless @team_update_successful
        failure_attrs.merge! team: @team.attributes
      end

      unless @student_update_successful
        failure_attrs.merge! student: @student.attributes
      end

      unless @team_update_successful && @student_update_successful
        failure_attrs.merge! grade: self.attributes
      end
    end
    failure_attrs
  end
end
