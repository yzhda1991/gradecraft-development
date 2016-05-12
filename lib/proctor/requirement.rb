module Proctor
  class Requirement
    attr_reader :outcome

    def initialize
      @outcome = yield
    end

    def passed?
      !!outcome
    end

    def failed?
      !outcome
    end
  end
end
