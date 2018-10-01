class LearningObjectiveObservedOutcome < ApplicationRecord
  belongs_to :cumulative_outcome, class_name: "LearningObjectiveCumulativeOutcome",
    foreign_key: :learning_objective_cumulative_outcomes_id
  belongs_to :learning_objective_level, foreign_key: :objective_level_id
  belongs_to :learning_objective_assessable, polymorphic: true

  belongs_to :grade, foreign_key: :learning_objective_assessable_id

  validates_presence_of :assessed_at, :learning_objective_level

  after_save :check_unlockables

  scope :for_student_visible_grades, -> { includes(:grade).where(grades: { student_visible: true }) }
  scope :shows_proficiency, -> do
    includes(:learning_objective_level)
    .where
    .not(learning_objective_levels: { flagged_value: 
      [
        LearningObjectiveLevel.flagged_values[:not_proficient], 
        LearningObjectiveLevel.flagged_values[:nearing_proficiency]
      ] 
    })
  end

  def self.observed_grade_outcomes_for(student, objective)
    cumulative_outcome = objective.cumulative_outcomes.for_user(student.id).first
    return nil if cumulative_outcome.nil?
    cumulative_outcome
      .observed_outcomes
      .for_student_visible_grades
      .includes(:learning_objective_level)
      .order("learning_objective_levels.flagged_value")
  end

  def check_unlockables
    if self.cumulative_outcome.learning_objective.is_a_condition?
      self.cumulative_outcome.learning_objective.unlock_keys.map(&:unlockable).each do |unlockable|
        unlockable.unlock!(grade.student)
      end
    end
  end
end
