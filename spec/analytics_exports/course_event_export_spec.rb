require "analytics"
require "./app/analytics_exports/course_event_export"

describe CourseEventExport do
  subject { described_class.new export_data }
  let(:export_data) do
    { users: [], assignments: [] }
  end

  it "includes Analytics::Export::Model" do
    expect(subject).to respond_to(:schema_records)
  end
end
