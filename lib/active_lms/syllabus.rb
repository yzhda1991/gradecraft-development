require "active_support"
require_relative "syllabus/canvas_syllabus"

module ActiveLMS
  class Syllabus
    include ActiveSupport::Inflector

    attr_reader :provider

    def initialize(provider, access_token)
      klass = constantize("ActiveLMS::#{camelize(provider)}Syllabus")
      @provider = klass.new access_token
    rescue NameError
      raise InvalidProviderError.new(provider)
    end

    def course(id)
      provider.course(id)
    end

    def courses
      provider.courses
    end

    def assignment(course_id, assignment_id, &exception_handler)
      provider.assignment(course_id, assignment_id, &exception_handler)
    end

    def assignments(course_id, assignment_ids=nil)
      provider.assignments(course_id, assignment_ids)
    end

    def grades(course_id, assignment_ids, grade_ids=nil, fetch_next=true, options={}, &exception_handler)
      provider.grades(course_id, assignment_ids, grade_ids, fetch_next, options, &exception_handler)
    end

    def update_assignment(course_id, assignment_id, params)
      provider.update_assignment(course_id, assignment_id, params)
    end

    def user(id)
      provider.user(id)
    end

    def users(course_id, fetch_next=true, options={})
      provider.users(course_id, fetch_next, options)
    end
  end
end
