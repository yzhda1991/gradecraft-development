require_relative "active_lms/configuration"
require_relative "active_lms/syllabus"
require_relative "active_lms/invalid_provider_error"

module ActiveLMS
  def self.configuration
    @configuration ||= ActiveLMS::Configuration.new
  end

  def self.configure
    yield configuration if block_given?
  end
end
