class FlaggedUser < ApplicationRecord
  belongs_to :course
  belongs_to :flagger, class_name: "User"
  belongs_to :flagged, class_name: "User"

  scope :for_course, ->(course) { where(course_id: course.id) }
  scope :for_flagged, ->(user) { where(flagged_id: user.id) }
  scope :for_flagger, ->(user) { where(flagger_id: user.id) }

  validates :course, presence: true
  validates :flagger, presence: true, course_membership: true, staff_flagger: true
  validates :flagged, presence: true, course_membership: true

  def self.flag!(course, flagger, flagged_id)
    create course_id: course.id, flagger_id: flagger.id, flagged_id: flagged_id
  end

  def self.flagged?(course, flagger, flagged_id)
    where(course_id: course.id, flagger_id: flagger.id, flagged_id: flagged_id).exists?
  end

  def self.unflag!(course, flagger, flagged_id)
    where(course_id: course.id, flagger_id: flagger.id, flagged_id: flagged_id).destroy_all
  end

  def self.flagged(course, flagger)
    where(course_id: course.id, flagger_id: flagger.id).map(&:flagged)
  end

  def self.toggle!(course, flagger, flagged_id)
    if flagged? course, flagger, flagged_id
      unflag! course, flagger, flagged_id
    else
      flag! course, flagger, flagged_id
    end
  end
end
