class LearningObjectiveLevel < ActiveRecord::Base
  enum flagged_value: [:exceeds_proficiency, :proficient, :nearing_proficiency, :not_proficient]

  belongs_to :objective, class_name: "LearningObjective", foreign_key: :objective_id

  validates_presence_of :name, :objective, :flagged_value

  scope :ordered, -> { order :order }

  def readable_flagged_value
    flagged_value.gsub("_", " ").titleize
  end
end
