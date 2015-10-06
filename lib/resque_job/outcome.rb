class ResqueJob::Performer::Outcome
  def initialize
    @result = yield
  end

  attr_reader :result

  def successful?
    @result == true
  end

  def failed?
    @result == false
  end
end
