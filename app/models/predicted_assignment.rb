class PredictedAssignment < SimpleDelegator
  attr_reader :user

  def initialize(assignment, user)
    @assignment = assignment
    @user = user
    super assignment
  end

  def grade
    @grade ||= PredictedGrade.new(Grade.find_or_create(assignment, user))
  end

  private

  attr_reader :assignment
end
