class Announcement < ActiveRecord::Base
  include Canable::Ables

  belongs_to :author, class_name: "User"
  belongs_to :course

  attr_accessible :author_id, :body, :course_id, :title

  validates :author, presence: true
  validates :body, presence: true
  validates :course, presence: true
  validates :title, presence: true

  default_scope { order "created_at DESC" }

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
end
