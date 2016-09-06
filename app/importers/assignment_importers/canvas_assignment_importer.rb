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
        assignment = course.assignments.build name: canvas_assignment["name"],
          description: canvas_assignment["description"],
          due_at: canvas_assignment["due_at"],
          full_points: canvas_assignment["points_possible"],
          assignment_type_id: assignment_type_id
        assignment.pass_fail = true if canvas_assignment["grading_type"] == "pass_fail"

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

  private

  def link_imported(provider_resource_id, provider_data, assignment)
    imported = ImportedAssignment.find_or_initialize_by(provider: :canvas,
      provider_resource_id: provider_resource_id)
    imported.assignment = assignment
    imported.provider_data = provider_data
    imported.save
  end
end
