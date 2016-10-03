require "light-service"
require "./app/services/group_services/iterates_assignment_groups_to_create_grades"

describe Services::Actions::IteratesAssignmentGroupsToCreateGrades do
  let(:assignment) { create(:assignment) }
  let(:grades_by_group_params) { { grades_by_group:
    { "0" => { "graded_by_id": "1", "instructor_modified" => "true", "raw_points" => "10", "status" => "graded" },
      "1" => { "graded_by_id": "1", "instructor_modified" => "true", "raw_points" => "20", "status" => "graded" } } }
    }

    it "expects an grades_by_group_params" do
      expect { described_class.execute assignment_id: assignment.id }.to \
        raise_error LightService::ExpectedKeysNotInContextError
    end

    it "expects an assignment_id" do
      expect { described_class.execute grades_by_group_params: grades_by_group_params }.to \
        raise_error LightService::ExpectedKeysNotInContextError
    end

    it "iterates the assignment groups" do
      expect(Services::CreatesGroupGrades).to receive(:create).exactly(grades_by_group_params[:grades_by_group].length).times.and_call_original
      described_class.execute assignment_id: assignment.id, grades_by_group_params: grades_by_group_params
    end
end
