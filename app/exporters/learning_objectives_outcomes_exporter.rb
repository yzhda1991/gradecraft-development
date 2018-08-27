class LearningObjectivesOutcomesExporter
  attr_accessor :course

  def initialize(course)
    @course = course
  end

  # gradebook spreadsheet export for course
  def learning_objective_outcomes
    CSV.generate do |csv|
      csv << learning_objective_outcomes_columns
      @course.students.order_by_name.each do |student|
        csv << student_data_for(student)
      end
    end
  end

  private

  def base_student_columns
    ["First Name", "Last Name", "Email", "Username", "Team"].freeze
  end

  def learning_objective_name_columns
    @course.learning_objectives.collect(&:name)
  end

  def learning_objective_outcomes_columns
    base_student_columns + learning_objective_name_columns
  end

  def base_student_methods
    [:first_name, :last_name, :email, :username]
  end

  def student_data_for(student)
    # add the base column names
    student_data = base_student_methods.inject([]) do |memo, method|
      memo << student.send(method)
    end

    student_data << student.team_for_course(@course).try(:name)

    # add the grades for the necessary assignments
    @course.learning_objectives.inject(student_data) do |memo, learning_objective|
      outcome = learning_objective.numeric_progress(student)
      memo << outcome
      memo
    end
  end
end
