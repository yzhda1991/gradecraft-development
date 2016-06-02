module GradeSchemeElementScoringExtension
  def for_score(score)
    elements = unscope(:order).order_by_low_points
    unless elements.empty?
      earned_element = elements.find { |element| element.within_range?(score) }
      earned_element ||= elements.last if score > elements.last.high_points
      earned_element ||= default if score < elements.first.low_points
    end
    earned_element
  end
end
