require "active_support"
require_relative "course_importer/canvas_course_importer"

module LMSImporter
  class CourseImporter
    include ActiveSupport::Inflector

    attr_reader :provider

    def initialize(provider, access_token)
      klass = constantize("LMSImporter::#{camelize(provider)}CourseImporter")
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

    def assignments(course_id)
      provider.assignments(course_id)
    end
  end
end
