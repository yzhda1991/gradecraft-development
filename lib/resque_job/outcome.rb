class ResqueJob::Outcome
  def initialize(result)
    @result = result
    @message = nil # todo: spec
    # @additional_messages = []
  end

  attr_reader :result
  attr_accessor :message #, :additional_messages

  def truthy?
    @result != false and @result != nil
  end
  alias_method :success?, :truthy?

  def falsey?
    @result == false || @result.nil?
  end
  alias_method :failure?, :falsey?

  def result_excerpt
    # "#{result}"[0..2000].split("\n").first rescue "#{result}"
    "#{result}"[0..2500] rescue "#{result}"
  end

  # def print_additional_messages
  #  @additional_messages.join(", ")
  # end
end
