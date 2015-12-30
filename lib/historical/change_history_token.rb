module Historical
  class ChangeHistoryToken
    attr_reader :attribute, :changes, :type

    def initialize(key, value, type)
      @attribute = key
      @changes = value
      @type =  type
    end

    def parse(options={})
      { change: "the #{attribute_name} from \"#{changes.first}\" to \"#{changes.last}\"" }
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
  end
end
