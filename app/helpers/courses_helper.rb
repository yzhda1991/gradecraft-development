module CoursesHelper
  def current_courses_cache_key(user)
    multi_cache_key :current_user_current_courses, user
  end

  def archived_courses_cache_key(user)
    multi_cache_key :current_user_archived_courses, user
  end

  def bust_course_list_cache(user)
    expire_fragment current_courses_cache_key(user)
    expire_fragment archived_courses_cache_key(user)
  end
end
