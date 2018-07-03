class MultipliersExporter
    attr_accessor :students, :assignment_types, :course

    def initialize(students, assignment_types, course)
      @students = students
      @assignment_types = assignment_types
      @course = course
    end

    def export
        CSV.generate do |csv|
            csv << headers
            @students.each do |s|
                csv << [s.first_name, s.last_name, s.email, s.weight_spent?(@course) ? "Yes" : "No",
                        @course.total_weights - s.total_weight_spent(@course),
                        weighted_assignment_types_multipliers(s).compact].flatten
            end
        end
    end

    private

    def headers
        ["First Name", "Last Name", "Email", "Fully Assigned", "Unassigned Number", weighted_assignment_types_names.compact].flatten
    end

    def weighted_assignment_types_names
        @assignment_types.map do |at|
            at.name if at.student_weightable?
        end
        # debugger
    end

    def weighted_assignment_types_multipliers(student)
        @assignment_types.map do |at|
            student.weight_for_assignment_type(at) if at.student_weightable?
        end
    end
end
