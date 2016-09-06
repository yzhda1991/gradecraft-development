require "light-service"
require "active_record_spec_helper"
require "./app/services/imports_lms_assignments/refresh_assignment"

describe Services::Actions::RefreshAssignment do
  let(:assignment) { create :assignment }
  let(:lms_assignment) do
    {
      id: "ASSIGNMENT_ID",
      course_id: 123,
      name: "This is an assignment from Canvas",
      description: "This is the description",
      due_at: "2012-07-01T23:59:00-06:00",
      points_possible: 123,
      grading_type: "points"
    }.stringify_keys
  end

  it "expects the assignment to refresh" do
    expect { described_class.execute lms_assignment: lms_assignment }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects the lms assignment details to refresh with" do
    expect { described_class.execute assignment: assignment }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "updates the assignment details" do
    result = described_class.execute assignment: assignment, lms_assignment: lms_assignment

    expect(result.assignment).to_not be_changed
    expect(result.assignment.name).to eq "This is an assignment from Canvas"
    expect(result.assignment.description).to eq "This is the description"
    expect(result.assignment.due_at).to eq DateTime.new(2012, 7, 1, 23, 59, 0, "-6")
    expect(result.assignment.full_points).to eq 123
  end
end
