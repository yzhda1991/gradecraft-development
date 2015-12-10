class CourseRouter
  def self.change!(user, course)
    user.default_course_id = course.id
    user.save
    course
  end
end
