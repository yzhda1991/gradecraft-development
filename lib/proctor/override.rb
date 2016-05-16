module Proctor
  class Override
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
