class CanvasAssignmentImporter
  attr_reader :successful, :unsuccessful
  attr_accessor :assignments

  def initialize(assignments)
    @assignments = assignments
    @successful = []
    @unsuccessful = []
  end

  def import(course, assignment_type_id)
    unless assignments.nil?
      assignments.each do |canvas_assignment|
        assignment = self.class.import_row course.assignments.build, canvas_assignment
        assignment.assignment_type_id = assignment_type_id

        if assignment.save
          link_imported canvas_assignment["id"],
            { course_id: canvas_assignment["course_id"] },
            assignment
          successful << assignment
        else
          unsuccessful << { data: canvas_assignment,
                            errors: assignment.errors.full_messages.join(", ") }
        end
      end
    end

    self
  end

  def self.import_row(assignment, canvas_assignment)
    assignment.name = canvas_assignment["name"]
    assignment.description = canvas_assignment["description"]
    assignment.due_at = canvas_assignment["due_at"]
    assignment.full_points = canvas_assignment["points_possible"]
    assignment.pass_fail = true if canvas_assignment["grading_type"] == "pass_fail"
    assignment
  end

  private

  def link_imported(provider_resource_id, provider_data, assignment)
    imported = ImportedAssignment.find_or_initialize_by(provider: :canvas,
      provider_resource_id: provider_resource_id)
    imported.assignment = assignment
    imported.provider_data = provider_data
    imported.save
  end
end
