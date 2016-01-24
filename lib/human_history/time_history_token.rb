module HumanHistory
  class TimeHistoryToken
    attr_reader :datetime

    def initialize(_, value, _)
      @datetime = value
    end

    def parse(options={})
      { self.class.token => datetime.strftime("%-I:%M %p") }
    end

    class << self
      def token
        :time
      end

      def tokenizable?(key, _, _)
        key == "recorded_at"
      end
    end
  end
end
