module Proctor
  module Conditions
    attr_accessor :requirements

    def self.included(base)
      @requirements = [] unless requirements
    end

    def add_requirements
    end

    def requirements_passed?
      requirements.all? {|requirement| requirement.passed? }
    end

    def add_requirement
      @requirements << Proctor::Requirement.new yield
    end
  end
end
