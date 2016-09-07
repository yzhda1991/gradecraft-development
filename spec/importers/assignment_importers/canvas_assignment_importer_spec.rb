require "active_record_spec_helper"
require "./app/importers/assignment_importers/canvas_assignment_importer"

describe CanvasAssignmentImporter do
  describe "#import" do
    it "returns empty results if there are no canvas assignments" do
      result = described_class.new(nil).import(nil, nil)

      expect(result.successful).to be_empty
      expect(result.unsuccessful).to be_empty
    end

    context "with some canvas assignments" do
      let(:assignment) { Assignment.unscoped.last }
      let(:assignment_type) { create :assignment_type }
      let(:canvas_assignment) do
        {
          id: canvas_assignment_id,
          course_id: 123,
          name: "This is an assignment from Canvas",
          description: "This is the description",
          due_at: "2012-07-01T23:59:00-06:00",
          points_possible: 123,
          grading_type: "points"
        }.stringify_keys
      end
      let(:canvas_assignment_id) { "ASSIGNMENT_1" }
      let(:course) { create :course }
      subject { described_class.new([canvas_assignment]) }

      it "creates the assignment" do
        expect { subject.import(course, assignment_type.id) }.to \
          change { Assignment.count }.by 1
        expect(assignment.course).to eq course
        expect(assignment.description).to eq "This is the description"
        expect(assignment.due_at).to eq DateTime.new(2012, 7, 1, 23, 59, 0, "-6")
        expect(assignment.name).to eq "This is an assignment from Canvas"
        expect(assignment.full_points).to eq 123
      end

      it "updates to a pass/fail assignment if the grading type is pass fail" do
        canvas_assignment["grading_type"] = "pass_fail"

        subject.import(course, assignment_type.id)

        expect(assignment.pass_fail).to eq true
        expect(assignment.full_points).to eq 0
      end

      it "adds the assignment to the course" do
        subject.import(course, assignment_type.id)

        expect(course.assignments).to eq [assignment]
      end

      it "assigns the assignment type to the assignment" do
        subject.import(course, assignment_type.id)

        expect(assignment.assignment_type).to eq assignment_type
      end

      it "creates a link to the assignment id in canvas" do
        subject.import(course, assignment_type.id)

        imported_assignment = ImportedAssignment.unscoped.last
        expect(imported_assignment.assignment).to eq assignment
        expect(imported_assignment.provider).to eq "canvas"
        expect(imported_assignment.provider_resource_id).to \
          eq canvas_assignment_id
        expect(imported_assignment.provider_data).to eq({ "course_id" => "123" })
        expect(imported_assignment.last_imported_at).to \
          be_within(1.second).of(DateTime.now)
      end

      it "contains a successful row if the assignment is valid" do
        result = subject.import(course, assignment_type.id)

        expect(result.successful.count).to eq 1
        expect(result.successful.last).to eq assignment
      end

      it "contains an unsuccessful row if the assignment is not valid" do
        canvas_assignment["name"] = ""

        result = subject.import(course, assignment_type.id)

        expect(result.unsuccessful.count).to eq 1
        expect(result.unsuccessful.first[:errors]).to eq "Name can't be blank"
      end
    end
  end
end
