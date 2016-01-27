require_relative "default_change_description_formatter"

module HumanHistory
  class RawScoreChangeDescriptionFormatter < DefaultChangeDescriptionFormatter
    def formattable?
      attribute == "raw_score" && type.classify == "Grade"
    end

    def change_description
      description = "the #{attribute_name} "
      description += "to #{changes.last}"
    end
  end
end
