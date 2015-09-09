class FlaggedUser < ActiveRecord::Base
  belongs_to :course
  belongs_to :flagger, class_name: "User"
  belongs_to :flagged, class_name: "User"

  validates :course, presence: true
  validates :flagger, presence: true, course_membership: true, staff_flagger: true
  validates :flagged, presence: true, course_membership: true

  def self.flag!(course, flagger, flagged_id)
    self.create course_id: course.id, flagger_id: flagger.id, flagged_id: flagged_id
  end
end
