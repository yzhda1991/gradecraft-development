module AnnouncementAbility
  def define_announcement_abilities(user, course)
    can :read, Announcement do |announcement|
      announcement.course.nil? || (announcement.course == course &&
        (announcement.recipient.present? ?
          announcement.recipient == user :
          announcement.course.users.include?(user)))
    end

    can [:create, :destroy], Announcement do |announcement|
      announcement.course.nil? || (announcement.course == course &&
        user.is_staff?(announcement.course))
    end

    can :update, Announcement, course_id: course.id,
      author_id: user.id
  end
end
