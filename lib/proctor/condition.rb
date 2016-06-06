# This class is used as the base condition class for wrapping the conditional
# methods that determine whether a condition set has passed for a given user
module Proctor
  class Condition
    # the condition attribute is the uncalled Proc containing the comparison
    #
    attr_reader :condition, :name

    def initialize(name:, &condition)
      # give the condition the name in case we need it later to figure out
      # what happened
      @name = name.to_s
      @condition = condition
    end

    # call the comparison to see what happened
    def outcome
      condition.call
    end

    # did the condition pass?
    def passed?
      !!outcome
    end

    # did the condition fail?
    def failed?
      !outcome
    end
  end
end
