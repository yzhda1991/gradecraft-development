module Toolkits
  module Exports
    module SubmissionsExportToolkit

      module Context
        def define_association_context
          let(:course) { create(:course) }
          let(:professor) { create(:user) }
          let(:team) { create(:team) }
          let(:assignment) { create(:assignment) }

          let(:submissions_export_associations) {{
            course: course,
            professor: professor,
            team: team,
            assignment: assignment
          }}
        end
      end

    end
  end
end

