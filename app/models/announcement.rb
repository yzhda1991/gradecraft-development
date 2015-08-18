class Announcement < ActiveRecord::Base
  include Canable::Ables

  belongs_to :author, class_name: "User"
  belongs_to :course
  has_many :states, class_name: "AnnouncementState", dependent: :destroy

  attr_accessible :author_id, :body, :course_id, :title

  validates :author, presence: true
  validates :body, presence: true
  validates :course, presence: true
  validates :title, presence: true

  default_scope { order "created_at DESC" }

  def self.read_count_for(student, course)
    AnnouncementState
      .joins(:announcement)
      .where(announcements: { course_id: course.id })
      .where(user_id: student.id).count
  end

  def self.unread_count_for(student, course)
    Announcement.where(course_id: course.id).count - read_count_for(student, course)
  end

  def creatable_by?(user)
    return true if !course.present?
    user.is_staff?(course)
  end

  def destroyable_by?(user)
    updatable_by? user
  end

  def updatable_by?(user)
    author_id == user.id
  end

  def viewable_by?(user)
    return true if !course.present?
    course.users.include? user
  end

  def abstract(words=25)
    body.split(/\s+/)[0..words].join(" ").strip
  end

  def deliver!
    if course
      course.students.each do |student|
        AnnouncementMailer.announcement_email(self, student).deliver_now
      end
    end
  end

  def mark_as_read!(user)
    if user.is_student?(course) &&
       !states.map(&:user_id).include?(user.id)
      states.create(user_id: user.id)
    end
  end

  def mark_as_unread!(user)
    states.destroy(states.where(user_id: user.id))
  end

  def read?(user)
    states.exists?(user_id: user.id)
  end

  def unread?(user)
    !read? user
  end

  def read_count
    states.count
  end

  def unread_count
    return 0 if course.nil?
    course.students.count - read_count
  end
end
