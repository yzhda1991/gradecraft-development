class Announcement < ApplicationRecord
  belongs_to :author, class_name: "User"
  belongs_to :course
  belongs_to :recipient, class_name: "User"
  has_many :states, class_name: "AnnouncementState", dependent: :destroy

  validates_presence_of :author, :body, :course, :title

  default_scope { order "created_at DESC" }

  def self.read_count_for(user, course)
    AnnouncementState
      .joins(:announcement)
      .where(announcements: { course_id: course.id, recipient_id: [nil, user.id] })
      .where(user_id: user.id).count
  end

  def self.unread_count_for(user, course)
    Announcement.where(course_id: course.id, recipient_id: [nil, user.id]).count -
      read_count_for(user, course)
  end

  def abstract(words=25)
    body.split(/\s+/)[0..words].join(" ").strip
  end

  def deliver!
    if !recipient.nil? && recipient.email_announcements?(course)
      AnnouncementMailer.announcement_email(self, recipient).deliver_now
    elsif !course.nil?
      course.course_memberships.active.participants.each do |p|
        if p.email_announcements?
          AnnouncementMailer.announcement_email(self, p.user).deliver_now
        end
      end
    end
  end

  def mark_as_read!(user)
    if course.user_ids.include?(user.id) &&
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
    return 1 - read_count if recipient.present?
    course.users.count - read_count
  end
end
