
  #gradebook spreadsheet export for course
  # todo: refactor this, maybe into a Gradebook class
  def csv_gradebook
    CSV.generate do |csv|
      @gradebook = Course::Gradebook.new(self)

      csv << @gradebook.assignment_columns
      self.students.each do |student|
        csv << @gradebook.student_data_for(student)
      end
    end
  end

  #gradebook spreadsheet export for course
  def csv_multiplied_gradebook
    CSV.generate do |csv|
      @multiplied_gradebook = Course::MultipliedGradebook.new(self)

      csv << @multiplied_gradebook.assignment_columns
      self.students.each do |student|
        csv << @multiplied_gradebook.student_data_for(student)
      end
    end
  end

  # todo: add unit tests for this somewhere else
  class Gradebook
    def initialize(course)
      @course = course
    end

    def base_assignment_columns
      ["First Name", "Last Name", "Email", "Username", "Team"]
    end

    def base_column_methods
      [:first_name, :last_name, :email, :username]
    end

    def assignments
      @assignments ||= @course.assignments.sort_by(&:created_at)
    end

    def assignment_columns
      base_assignment_columns + assignment_name_columns
    end

    def assignment_name_columns
      assignments.collect(&:name)
    end

    def student_data_for(student)
      # add the base column names
      student_data = base_column_methods.inject([]) do |memo, method|
        memo << student.send(method)
      end
      # todo: we need to pre-fetch the course teams for this
      student_data << student.team_for_course(@course).try(:name)

      # add the grades for the necessary assignments, todo: improve the performance here
      assignments.inject(student_data) do |memo, assignment|
        grade = assignment.grade_for_student(student)
        if grade and grade.is_student_visible?
          memo << grade.try(:raw_score)
        else
          memo << ''
        end
        memo
      end
    end
  end

  class MultipliedGradebook < Gradebook
    def assignment_name_columns
      assignments.collect do |assignment|
        [ assignment.name, assignment.name ]
      end.flatten
    end

    def student_data_for(student)
      # add the base column names
      student_data = base_column_methods.inject([]) do |memo, method|
        memo << student.send(method)
      end
      # todo: we need to pre-fetch the course teams for this
      student_data << student.team_for_course(@course).try(:name)

      # add the grades for the necessary assignments, todo: improve the performance here
      assignments.inject(student_data) do |memo, assignment|
        grade = assignment.grade_for_student(student)
        if grade and grade.is_student_visible?
          memo << grade.try(:score)
        end
        memo
      end
    end
  end
