require "analytics/export"
require "./app/analytics_exports/context_filters/assignments_context_filter"
 
describe AssignmentsContextFilter do
  subject { described_class.new course_context }
  let(:course_context) { double(:some_context, class: "CourseExportContext") }

  before do
    allow(subject).to receive(:valid_context_type?) { true }
  end

  it "inherits from Analytics::Export::ContextFilter" do
    expect(subject).to respond_to :validate_context_type
  end

  describe "#assignment_names" do
    it "builds a hash mapping id to name for each assignment" do
      assignments = [
        double(:assignment, id: 1, name: "writing"),
        double(:assignment, id: 2, name: "rithmatic")
      ]

      allow(subject.context).to receive(:assignments) { assignments }

      expect(subject.assignment_names).to eq({ 1 => "writing", 2 => "rithmatic" })
    end
  end
end
