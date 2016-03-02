require_relative "../string"

module HumanHistory
  class EventHistoryToken
    attr_reader :event

    def initialize(_, value, _)
      @event = value
    end

    def parse(options={})
      { self.class.token => event == "update" ? "changed" :
        Gradecraft::String.new(event).past_tense }
    end

    class << self
      def token
        :event
      end

      def tokenizable?(key, _, _)
        key == "event"
      end
    end
  end
end
