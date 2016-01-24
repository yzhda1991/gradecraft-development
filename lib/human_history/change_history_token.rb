module HumanHistory
  class ChangeHistoryToken
    attr_reader :attribute, :changes, :type

    def initialize(key, value, type)
      @attribute = key
      @changes = value
      @type =  type
    end

    def parse(options={})
      { change: change_description }
    end

    class << self
      def token
        :change
      end

      def tokenizable?(key, value, changeset)
        !["created_at", "updated_at"].include?(key) &&
          !changeset.keys.include?("created_at") && value.is_a?(Array)
      end
    end

    private

    def attribute_name
      type.classify.constantize.human_attribute_name(attribute).downcase
    end

    def change_description
      description = "the #{attribute_name} "
      description += "from #{format_change changes.first} " if include_from? changes.first
      description += "to #{format_change changes.last}"
    end

    def format_change(change)
      requires_quotes?(change) ? "\"#{change}\"" : change
    end

    def include_from?(change)
      !change.nil? && (!change.respond_to?(:empty?) || !change.empty?)
    end

    def requires_quotes?(change)
      !change.is_a?(Integer) && !change.is_a?(TrueClass) && !change.is_a?(FalseClass)
    end
  end
end
