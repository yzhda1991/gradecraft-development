class ResqueJob::Outcome
  def initialize(result)
    @result = result
    @message = nil # todo: spec
  end

  attr_reader :result
  attr_accessor :message

  def truthy?
    @result != false and @result != nil
  end
  alias_method :success?, :truthy?

  def falsey?
    @result == false || @result.nil?
  end
  alias_method :failure?, :falsey?

  def result_excerpt
    "#{result}"[0..100].split("\n").first rescue "#{result}"
  end
end
