class PredictedAssignment < SimpleDelegator
  attr_reader :user

  def initialize(assignment, user)
    @assignment = assignment
    @user = user
    super assignment
  end

  def grade
    if @grade.nil?
      grade = user.present? ? Grade.find_or_create(assignment, user) : NullGrade.new
      @grade = PredictedGrade.new(grade)
    end
    @grade
  end

  private

  attr_reader :assignment
end
