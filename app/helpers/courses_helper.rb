module CoursesHelper
  def current_courses_cache_key(user)
    multi_cache_key :current_user_current_courses, user
  end

  def archived_courses_cache_key(user)
    multi_cache_key :current_user_archived_courses, user
  end

  def available_roles(course)
    roles = [["Student", "student"]]
    if current_user.is_professor?(course) || current_user.is_admin?(course)
      roles << ["GSI", "gsi"]
      roles << ["Professor", "professor"]
      roles << ["Observer", "observer"]
    end
    roles << ["Admin", "admin"] if current_user.is_admin?(course)
    roles
  end

  def bust_course_list_cache(user)
    expire_fragment current_courses_cache_key(user)
    expire_fragment archived_courses_cache_key(user)
  end
end
