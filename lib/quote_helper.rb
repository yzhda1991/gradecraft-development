module QuoteHelper
  def remove_smart_quotes(string)
    regex = Regexp.new smart_quote_characters.join("|")
    string.gsub(regex, "")
  end

  def smart_quote_characters
    double_smart_quote_characters + single_smart_quote_characters
  end

  def double_smart_quote_characters
    ["\u201C", "\u201D"].freeze
  end

  def single_smart_quote_characters
    ["\u2018", "\u2019"].freeze
  end
end
