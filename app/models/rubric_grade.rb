class RubricGrade < ActiveRecord::Base
  belongs_to :submission, touch: true
  belongs_to :metric, touch: true
  belongs_to :tier, touch: true
  belongs_to :student, touch: true
  belongs_to :assignment, touch: true

  attr_accessible :metric_name, :metric_description, :max_points, :tier_name,
    :tier_description, :points, :submission_id, :metric_id, :tier_id, :order,
    :student_id, :assignment_id, :comments

  validates :max_points, presence: true
  validates :metric_name, presence: true
  validates :order, presence: true
  validates :student_id, presence: true
  validate :submission_or_assignment_present

  private

    def submission_or_assignment_present
      submission_id.present? or assignment_id.present?
    end
end
