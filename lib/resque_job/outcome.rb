class ResqueJob::Outcome
  def initialize(result, options={})
    @result = result
    @message = nil
    @options = options
  end

  attr_reader :result, :options
  attr_accessor :message

  def truthy?
    @result != false && @result != nil
  end
  alias success? truthy?

  def falsey?
    @result == false || @result.nil?
  end
  alias failure? falsey?

  def result_excerpt
    return result unless options[:max_result_size]
    "#{result}"[0..@options[:max_result_size].to_i] rescue "#{result}"
  end
end
