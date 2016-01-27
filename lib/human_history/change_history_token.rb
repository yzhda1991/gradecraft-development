require_relative "default_change_description_formatter"

module HumanHistory
  class ChangeHistoryToken
    attr_reader :attribute, :changes, :type

    def initialize(key, value, type)
      @attribute = key
      @changes = value
      @type =  type
    end

    def parse(options={})
      formatters = default_options
        .merge(options)[:change_description_formatters]

      { change: change_description(formatters) }
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

    def change_description(formatters)
      formatters.each do |formatter_type|
        formatter = formatter_type.new(attribute, changes, type)
        if formatter.formattable?
          return formatter.change_description
        end
      end
    end

    def default_options
      { change_description_formatters: [DefaultChangeDescriptionFormatter] }
        .freeze
    end
  end
end
