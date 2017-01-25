module Services
  module Actions
    class CreatesOrUpdatesCourseByUID
      extend LightService::Action

      expects :course_attributes
      promises :course

      executed do |context|
        course_attributes = context.course_attributes.merge(year: Date.today.year)
        course = Course.find_or_initialize_by(lti_uid: course_attributes[:lti_uid])
        course.update! course_attributes
        context[:course] = course
      end
    end
  end
end
