class LearningObjective < ApplicationRecord
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

  def progress(student, include_details=false)
    cumulative_outcome = cumulative_outcomes.for_user(student.id).first
    return "Not Started" if cumulative_outcome.nil?

    if course.objectives_award_points?
      point_progress_for cumulative_outcome, include_details
    else
      grade_outcome_progress_for cumulative_outcome, include_details
    end
  end

  def point_progress_for(cumulative_outcome, include_details)
    earned = earned_assignment_points cumulative_outcome
    return "Not Started" if earned.zero?
    earned < points_to_completion ? in_progress_str(earned, points_to_completion, include_details) : "Completed"
  end

  def grade_outcome_progress_for(cumulative_outcome, include_details)
    outcomes = observed_outcomes(cumulative_outcome)
    return "Not Started" if outcomes.empty?
    return "Failed" if outcomes.any? { |o| o.learning_objective_level.try(:failed?) }

    proficient_outcomes = observed_outcomes(cumulative_outcome, true)
    proficient_outcomes.count < count_to_achieve ? in_progress_str(proficient_outcomes.count, count_to_achieve, include_details) : "Completed"
  end

  def observed_outcomes(cumulative_outcome, proficient_only=false)
    outcomes = cumulative_outcome
      .observed_outcomes
      .for_student_visible_grades
    outcomes.shows_proficiency if proficient_only
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
    str = "In Progress"
    return str unless include_details
    "#{str} (#{earned}/#{total})"
  end
end
