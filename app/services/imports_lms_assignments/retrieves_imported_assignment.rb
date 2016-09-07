module Services
  module Actions
    class RetrievesImportedAssignment
      extend LightService::Action

      expects :assignment, :provider
      promises :imported_assignment

      executed do |context|
        assignment = context.assignment
        provider = context.provider

        context.imported_assignment =
          ImportedAssignment.where(assignment_id: assignment.id, provider: provider).first

        if context.imported_assignment.nil?
          context.fail! "Assignment was not imported from #{provider.capitalize}", 422
        end
      end
    end
  end
end
