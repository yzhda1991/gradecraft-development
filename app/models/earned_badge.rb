class EarnedBadge < ApplicationRecord
  include AutoAwardOnUnlock

  before_validation :add_associations

  belongs_to :course
  belongs_to :badge
  belongs_to :student, class_name: "User"
  belongs_to :submission # Optional
  belongs_to :grade # Optional
  belongs_to :awarded_by, class_name: 'User'
  has_many :badge_files, through: :badge

  validates_presence_of :badge, :course, :student

  before_save :update_visibility
  after_save :check_unlockables

  validates_with EarnableValidator, attributes: [:badge, :student], on: :create

  delegate :name, :description, :icon, to: :badge

  scope :for_course, ->(course) { where(course_id: course.id) }
  scope :for_student, ->(student) { where(student_id: student.id) }
  scope :student_visible, -> { where(student_visible: true) }
  scope :order_by_created_at, -> { order("created_at ASC") }

  scope :earned_by_active_students, -> do
    joins("INNER JOIN course_memberships ON "\
      "course_memberships.course_id = earned_badges.course_id AND "\
      "course_memberships.user_id = earned_badges.student_id")
      .where("course_memberships.active = true")
      .references(:course_membership, :earned_badge)
  end

  def check_unlockables
    if self.badge.is_a_condition?
      self.badge.unlock_keys.map(&:unlockable).each do |unlockable|
        unlock_state = unlockable.unlock!(student)
        unlock_state { |unlock_state| check_for_auto_awarded_badge(unlock_state) }
      end
    end
  end

  def points
    self.badge.full_points
  end

  private

  def update_visibility
    if grade.present?
      self.student_visible = GradeProctor.new(grade).viewable?
    else
      self.student_visible = true
    end
    true
  end

  def add_associations
    self.course_id ||= badge.course_id
  end

  def check_for_auto_awarded_badge(unlock_state)
    award_badge(unlock_state, {
      student_id: student.id,
      course_id: course.id
    })
  end
end
