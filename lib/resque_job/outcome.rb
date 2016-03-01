class ResqueJob::Outcome
  def initialize(result, options={})
    @result = result
    @message = nil # todo: spec
    @options = options
    # @additional_messages = []
  end

  attr_reader :result
  attr_accessor :message #, :additional_messages

  def truthy?
    @result != false && @result != nil
  end
  alias success? truthy?

  def falsey?
    @result == false || @result.nil?
  end
  alias failure? falsey?

  def result_excerpt
    # "#{result}"[0..2000].split("\n").first rescue "#{result}"
    if @options[:max_result_size]
      "#{result}"[0..@options[:max_result_size].to_i] rescue "#{result}"
    else
      "#{result}"
    end
  end

  # def print_additional_messages
  #  @additional_messages.join(", ")
  # end
end
