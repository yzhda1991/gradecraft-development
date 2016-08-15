require "analytics"
require "./app/analytics_exports/course_event_export"

describe CourseEventExport do
  subject { described_class.new context: context }
  let(:context) { double(:some_context).as_null_object }

  it "includes Analytics::Export::Model" do
    expect(subject.class).to respond_to(:column_mapping)
  end

  it "uses events as the focus of the export" do
    expect(described_class.instance_variable_get :@export_focus).to eq :events
  end

  it "has a column mapping" do
    expect(described_class.instance_variable_get :@column_mapping).to eq(
      {
        username: :username,
        role: :user_role,
        user_id: :user_id,
        page: :page,
        date_time: :formatted_event_timestamp
      }
    )
  end

  describe "#username" do
    before do
      allow(context).to receive(:usernames).and_return({ 20 => "herman" })
    end

    it "takes the username from context#usernames if one exists" do
      event = double(:event, user_id: 20)
      expect(subject.username(event)).to eq "herman"
    end

    it "just provides the user_id if no username was found" do
      event = double(:event, user_id: 9000)
      expect(subject.username(event)).to eq "[user id: 9000]"
    end
  end

  describe "#page" do
  end

  describe "#formatted_event_timestamp" do
  end
end
