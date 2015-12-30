class HistoryTokenParser
  attr_reader :tokenizer

  def initialize(tokenizer)
    @tokenizer = tokenizer
  end

  def parse(options={})
    structure = {}
    tokenizer.tokenize.tokens.each do |token|
      structure.merge!(token.parse(options)) do |key, v1, v2|
        "#{v1} and #{v2}"
      end
    end
    structure
  end
end
