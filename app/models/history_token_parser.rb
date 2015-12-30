class HistoryTokenParser
  attr_reader :tokenizer

  def initialize(tokenizer)
    @tokenizer = tokenizer
  end

  def parse(options={})
    structure = {}
    tokenizer.tokenize.tokens.each do |token|
      structure.merge! token.parse(options)
    end
    structure
  end
end
