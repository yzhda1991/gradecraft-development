class PredictedAssignment < SimpleDelegator
  attr_reader :current_user, :student

  def initialize(assignment, current_user, student)
    @assignment = assignment
    @current_user = current_user
    @student = student
    super assignment
  end

  def grade
    if @grade.nil?
      grade = student.present? ? Grade.find_or_create(assignment, student) : NullGrade.new
      @grade = PredictedGrade.new(grade, current_user)
    end
    @grade
  end

  private

  attr_reader :assignment
end
