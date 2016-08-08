require "analytics"
require "./app/analytics_exports/course_user_aggregate_export"

describe CourseUserAggregateExport do
  subject { described_class.new export_data }
  let(:export_data) do
    {
      events: [],
      predictor_events: [],
      user_pageviews: [],
      user_logins: [],
      user_predictor_pageviews: []
    }
  end

  it "includes Analytics::Export::Model" do
    expect(subject).to respond_to(:schema_records)
  end
end
