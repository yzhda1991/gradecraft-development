class LearningObjectiveLevel < ActiveRecord::Base
  enum flagged_value: [:exceeds_proficiency, :proficient, :nearing_proficiency, :not_proficient]

  belongs_to :objective, class_name: "LearningObjective", foreign_key: :objective_id
  belongs_to :course

  validates_presence_of :name, :objective, :flagged_value

  scope :ordered, -> { order :order }

  class << self
    def flagged_values_to_h
      flagged_values.map do |k, v|
        { value: v, display_string: to_readable_flagged_value(k), original_key: k }
      end
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
