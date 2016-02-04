module GradeSchemeElementScoringExtension
  def for_score(score)
    elements = unscope(:order).order_by_low_range
    unless elements.empty?
      element = elements.find { |element| element.within_range?(score) }
      element ||= elements.last if score > elements.last.high_range
      element ||= default if score < elements.first.low_range
    end
    element
  end
end
