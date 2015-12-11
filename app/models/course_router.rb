class CourseRouter
  class << self
    def change!(user, course)
      user.current_course_id = course.id
      user.save
      course
    end

    def current_course_for(user, current_course_id=nil)
      return nil if user.nil?
      course = user.courses.find_by(id: current_course_id) unless current_course_id.nil?
      course ||= user.current_course
      course ||= user.courses.first
      course
    end
  end
end
