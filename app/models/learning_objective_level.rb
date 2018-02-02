class LearningObjectiveLevel < ActiveRecord::Base
  enum flagged_value: [:exceeds_proficiency, :proficient, :nearing_proficiency, :not_proficient]

  belongs_to :objective, class_name: "LearningObjective", foreign_key: :objective_id

  validates_presence_of :name, :objective, :flagged_value

  scope :ordered, -> { order :order }

  class << self
    # Returns hash with flagged_value and its display string
    # { exceeds_proficiency => "Exceeds Proficiency", ... }
    def readable_flagged_values
      flagged_values.map { |k, v| [k, to_readable_flagged_value(k)] }.to_h
    end

    def to_readable_flagged_value(value)
      value.tr("_", " ").titleize
    end
  end

  def readable_flagged_value
    LearningObjectiveLevel.to_readable_flagged_value(flagged_value)
  end

  def failed?
    not_proficient?
  end
end
