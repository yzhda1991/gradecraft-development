module Proctor
  module Conditions
    attr_accessor :requirements, :overrides
    attr_reader :proctor_conditions_included

    def self.included(base)
      return if proctor_conditions_included
      @proctor_conditions_included = true
      @requirements = []
      @overrides = []
    end

    def add_requirement
      @requirements << Proctor::Requirement.new yield
    end

    def add_override
      @overrides << Proctor::Override.new yield
    end

    def requirements_passed?
      requirements.all? {|requirement| requirement.passed? }
    end

    def valid_overrides_present?
      overrides.any? {|override| override.valid? }
    end
  end
end
