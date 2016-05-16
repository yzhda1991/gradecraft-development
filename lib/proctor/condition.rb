module Proctor
  class Condition
    attr_reader :condition, :name

    def initialize(name:, &condition)
      @name = name
      @condition = condition
    end

    def outcome
      condition.call
    end

    def passed?
      !!outcome
    end

    def failed?
      !outcome
    end
  end
end
