class LearningObjectiveCumulativeOutcome < ApplicationRecord
  belongs_to :user
  belongs_to :learning_objective

  has_many :observed_outcomes, class_name: "LearningObjectiveObservedOutcome",
    foreign_key: :learning_objective_cumulative_outcomes_id, dependent: :destroy

  validates_presence_of :user, :learning_objective
  validates :user, uniqueness: { scope: :learning_objective,
    message: "should be unique per learning objective" }

  scope :for_user, -> (user_id) { where user_id: user_id }
end
