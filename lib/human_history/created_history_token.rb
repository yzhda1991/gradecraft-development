module HumanHistory
  class CreatedHistoryToken
    attr_reader :type

    def initialize(_, _, type)
      @type = type
    end

    def parse(options={})
      { change: "the #{type_name}" }
    end

    class << self
      def token
        :change
      end

      def tokenizable?(key, _, _)
        key == "created_at"
      end
    end

    private

    def type_name
      type.humanize(capitalize: false)
    end
  end
end
