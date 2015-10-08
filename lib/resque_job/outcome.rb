class ResqueJob::Outcome
  def initialize(result)
    @result = result
  end

  attr_reader :result

  def truthy?
    @result != false and @result != nil
  end
  alias_method :success?, :truthy?

  def falsey?
    @result == false || @result.nil?
  end
  alias_method :failure?, :falsey?
end
