class ResqueJob::Outcome
  def initialize(result, options={})
    @result = result
    @options = options
  end

  attr_accessor :message, :result, :options

  def success?
    result != false && result != nil
  end

  def failure?
    result == false || result.nil?
  end

  def result_excerpt
    return result unless options[:max_result_size]
    "#{result}"[0..options[:max_result_size].to_i]
  end
end
