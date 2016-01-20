require_relative "array_merge_strategy"
require_relative "default_merge_strategy"

module HumanHistory
  class HistoryTokenParser
    attr_reader :tokenizer

    def initialize(tokenizer)
      @tokenizer = tokenizer
    end

    def parse(options={})
      merge_strategy = options.delete(:merge_strategy) || :and

      structure = {}
      tokenizer.tokenize.tokens.each do |token|
        structure.merge!(token.parse(options)) do |key, v1, v2|
          merge_similar_tokens merge_strategy, v1, v2
        end
      end
      structure
    end

    private

    def merge_similar_tokens(strategy, left, right)
      klass = "#{strategy.capitalize}MergeStrategy"
      klass = HumanHistory.const_defined?(klass) ? HumanHistory.const_get(klass) :
        HumanHistory::DefaultMergeStrategy
      klass.new(left, right).merge!(strategy: strategy)
    end
  end
end
