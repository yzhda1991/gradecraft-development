require "analytics"
require "./app/analytics_exports/course_event_export"

describe CourseEventExport do
  subject { described_class.new context: context }
  let(:context) { double(:some_context).as_null_object }
  let(:users_context_filter) { double(:context_filter).as_null_object }

  before do
    allow(subject).to receive(:context_filters).and_return({
      users: users_context_filter
    })
  end

  it "includes Analytics::Export::Model" do
    expect(subject.class).to respond_to(:column_mapping)
  end

  it "uses events as the focus of the export" do
    expect(described_class.instance_variable_get :@export_focus).to eq :events
  end

  it "uses the users context filter" do
    filter_names = described_class.instance_variable_get :@context_filter_names
    expect(filter_names).to eq [:users]
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
      allow(users_context_filter).to receive(:usernames)
        .and_return({ 20 => "herman" })
    end

    it "takes the username from context#usernames if one exists" do
      event = double(:event, user_id: 20)
      expect(subject.username event).to eq "herman"
    end

    it "just provides the user_id if no username was found" do
      event = double(:event, user_id: 9000)
      expect(subject.username event).to eq "[user id: 9000]"
    end
  end

  describe "#page" do
    it "uses the event page if one exists" do
      event = double(:event, page: "http://somepage.com")
      expect(subject.page event).to eq "http://somepage.com"
    end

    it "tells us if the event has no page" do
      event = double(:event)
      expect(subject.page event).to eq "[n/a]"
    end
  end

  describe "#formatted_event_timestamp" do
    it "returns a formated created_at timestamp" do
      parsed_time = Date.parse("Mar 20 2010").to_time
      event = double(:event, created_at: parsed_time)

      expect(subject.formatted_event_timestamp event).to eq "2010-03-20 00:00:00"
    end
  end
end
