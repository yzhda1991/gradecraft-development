class ResqueJob::Performer::Outcome
  def initialize(result)
    @result = result
  end

  attr_reader :result

  def truthish?
    @result != false and @result != nil
  end

  def falseish?
    @result == false || @result.nil?
  end

  def success?
    truthish?
  end

  def failure?
    falseish?
  end
end
