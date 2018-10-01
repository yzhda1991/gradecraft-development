class LearningObjective < ApplicationRecord
  include UnlockableCondition
  
  NOT_STARTED_STATUS = "Not Started".freeze
  IN_PROGRESS_STATUS = "In Progress".freeze
  COMPLETED_STATUS = "Completed".freeze

  belongs_to :course
  belongs_to :category, class_name: "LearningObjectiveCategory", optional: true

  has_many :levels, class_name: "LearningObjectiveLevel",
    foreign_key: :objective_id, dependent: :destroy
  has_many :cumulative_outcomes, class_name: "LearningObjectiveCumulativeOutcome",
    foreign_key: :learning_objective_id, dependent: :destroy

  has_many :learning_objective_links, foreign_key: :objective_id, dependent: :destroy
  has_many :assignments, source: :learning_objective_linkable,
    source_type: Assignment.name, through: :learning_objective_links

  accepts_nested_attributes_for :learning_objective_links

  validates_presence_of :course, :name
  validate :count_to_achieve_or_points
  validates :count_to_achieve, numericality: { greater_than_or_equal_to: 0 }, allow_nil: true
  validates_with MatchesCourseOnLinkedCategory

  scope :ordered_by_name, -> { order :name }

  def completed?(student)
    progress(student) == COMPLETED_STATUS
  end

  def linked_assignments_count
    learning_objective_links.count
  end

  def progress(student, include_details=false)
    cumulative_outcome = cumulative_outcomes.for_user(student.id).first
    return NOT_STARTED_STATUS if cumulative_outcome.nil?

    if course.objectives_award_points?
      point_progress_for cumulative_outcome, include_details
    else
      grade_outcome_progress_for cumulative_outcome, include_details
    end
  end

  def numeric_progress_for_student(student)
    cumulative_outcome = LearningObjectiveCumulativeOutcome.for_user(student.id).for_objective(self.id).first
    numeric_progress_for_outcome cumulative_outcome
  end

  def numeric_progress_for_outcome(cumulative_outcome)
    return 0 if cumulative_outcome.nil?

    cumulative_outcome
      .observed_outcomes
      .for_student_visible_grades
      .shows_proficiency
      .count
  end

  def percent_complete(student)
    cumulative_outcome = LearningObjectiveCumulativeOutcome.for_user(student.id).for_objective(self.id).first

    if course.objectives_award_points?
      earned_points = earned_assignment_points(cumulative_outcome)
      return 100 if earned_points >= points_to_completion
      percentage = earned_points.to_f / points_to_completion.to_f
    else
      percentage = numeric_progress_for_outcome(cumulative_outcome).to_f / count_to_achieve.to_f
    end
    (percentage * 100).round(2)
  end

  def point_progress_for(cumulative_outcome, include_details)
    earned = earned_assignment_points cumulative_outcome
    return NOT_STARTED_STATUS if earned.zero?
    earned < points_to_completion ? in_progress_str(earned, points_to_completion, include_details) : COMPLETED_STATUS
  end

  def grade_outcome_progress_for(cumulative_outcome, include_details)
    outcomes = observed_outcomes(cumulative_outcome)
    return NOT_STARTED_STATUS if outcomes.empty?

    proficient_outcomes = observed_outcomes(cumulative_outcome, true)
    proficient_outcomes.count < count_to_achieve ? in_progress_str(proficient_outcomes.count, count_to_achieve, include_details) : COMPLETED_STATUS
  end

  def observed_outcomes(cumulative_outcome, proficient_only=false)
    outcomes = cumulative_outcome
      .observed_outcomes
      .for_student_visible_grades
    outcomes = outcomes.shows_proficiency if proficient_only
    outcomes
  end

  private

  def earned_assignment_points(cumulative_outcome)
    grades = observed_outcomes(cumulative_outcome, true).map do |o|
      o.grade.tap { |grade| grade.present? && !grade.excluded_from_course_score? && !grade.score.nil? }
    end

    grades.pluck(:final_points).sum || 0
  end

  # Ensure that objectives have either a count to achieve or a points to completion value
  def count_to_achieve_or_points
    errors.add(:base, "must have either a count_to_achieve or points_to_completion") \
      if count_to_achieve.nil? && points_to_completion.nil?
  end

  def in_progress_str(earned, total, include_details)
    return IN_PROGRESS_STATUS unless include_details
    "#{IN_PROGRESS_STATUS} (Earned #{earned} of #{total} tries)"
  end
end
