module Proctor
  module Conditions
    attr_accessor :requirements, :overrides

    def self.included(base)
      reset_conditions
    end

    def for(condition_set)
      reset_conditions
      send "#{condition_set}_conditions"
    end

    def satisfied?(condition_set)
      requirements_passed? || valid_overrides_present?
    end

    def reset_conditions
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
