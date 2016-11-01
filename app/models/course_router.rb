class CourseRouter
  class << self
    def change!(user, course)
      user.current_course_id = course.id
      user.save
      course
    end

    def current_course_for(user, current_course_id=nil)
      return nil if user.nil?
      course = user.courses.where(id: current_course_id).first
      course ||= user.current_course
      course ||= user.courses.first
      course
    end
  end
end
