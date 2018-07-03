class MultipliersController < ApplicationController
    def export
        students = current_course.students_being_graded.order_by_name
        assignment_types = current_course.assignment_types.ordered

        respond_to do |format|
            format.csv { send_data MultipliersExporter.new(students, assignment_types, current_course).export(), filename: "#{ current_course.name } multipliers - #{ Date.today }.csv" }
        end
    end
end
