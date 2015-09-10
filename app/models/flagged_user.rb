class FlaggedUser < ActiveRecord::Base
  belongs_to :course
  belongs_to :flagger, class_name: "User"
  belongs_to :flagged, class_name: "User"

  validates :course, presence: true
  validates :flagger, presence: true, course_membership: true, staff_flagger: true
  validates :flagged, presence: true, course_membership: true

  def self.flag!(course, flagger, flagged_id)
    create course_id: course.id, flagger_id: flagger.id, flagged_id: flagged_id
  end

  def self.unflag!(course, flagger, flagged_id)
    where(course_id: course.id, flagger_id: flagger.id, flagged_id: flagged_id).destroy_all
  end

  def self.toggle!(course, flagger, flagged_id)
    if where(course_id: course.id, flagger_id: flagger.id, flagged_id: flagged_id).exists?
      unflag! course, flagger, flagged_id
    else
      flag! course, flagger, flagged_id
    end
  end
end
