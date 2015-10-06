class ResqueJob::Performer::Outcome
  def initialize
    @result = yield
  end

  attr_reader :result

  def add_success_condition
  end

  def successful?
    @result == true
  end

  def failed?
    @result == false || @result.nil?
  end
end
