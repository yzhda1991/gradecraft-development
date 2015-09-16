module AnnouncementsHelper
  def unread_cache_key(user, course)
    "#{user.cache_key}/#{course.cache_key}/unread_count"
  end

  def unread_count_for(user, course)
    Rails.cache.fetch(unread_cache_key(user, course)) do
      Announcement.unread_count_for user, course
    end
  end
end
