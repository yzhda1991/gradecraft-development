class EarnedBadge < ActiveRecord::Base

  before_validation :add_associations

  belongs_to :course, touch: true
  belongs_to :badge
  belongs_to :student, class_name: "User", touch: true
  belongs_to :submission # Optional
  belongs_to :grade # Optional
  belongs_to :awarded_by, class_name: 'User'
  has_many :badge_files, through: :badge

  validates_presence_of :badge, :course, :student

  before_save :update_visibility
  after_save :check_unlockables


  validate :earnable?, :on => :create

  delegate :name, :description, :icon, :points, to: :badge

  scope :for_course, ->(course) { where(course_id: course.id) }
  scope :for_student, ->(student) { where(student_id: student.id) }
  scope :student_visible, -> { where(student_visible: true) }
  scope :order_by_created_at, -> { order("created_at ASC") }

  def check_unlockables
    if self.badge.is_a_condition?
      self.badge.unlock_keys.map(&:unlockable).each do |unlockable|
        unlockable.check_unlock_status(student)
      end
    end
  end

  def points
    self.badge.full_points || 0
  end

  private

  def update_visibility
    self.student_visible = GradeProctor.new(grade).viewable? if grade.present?
    true
  end

  def add_associations
    self.course_id ||= badge.course_id
  end

  def earnable?
    return true if self.badge.can_earn_multiple_times? ||
      self.badge.available_for_student?(self.student)
    errors.add :base, " Oops, they've already earned the '#{name}' #{course.badge_term.downcase}."
    return false
  end
end
