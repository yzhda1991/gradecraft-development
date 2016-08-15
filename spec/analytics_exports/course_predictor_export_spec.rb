require "analytics"
require "./app/analytics_exports/course_predictor_export"

describe CoursePredictorExport do
  subject { described_class.new context: context }
  let(:context) { double(:context).as_null_object }

  it "includes Analytics::Export::Model" do
    expect(subject.class).to respond_to(:column_mapping)
  end

  it "uses events as the focus of the export" do
    expect(described_class.instance_variable_get :@export_focus).to eq :predictor_events
  end

  it "has a column mapping" do
    expect(described_class.instance_variable_get :@column_mapping).to eq(
      {
        username: :username,
        role: :user_role,
        user_id: :user_id,
        assignment: :assignment_name,
        assignment_id: :assignment_id,
        prediction: :predicted_points,
        possible: :possible_points,
        date_time: :formatted_event_timestamp
      }
    )
  end

  describe "#assignment_name" do
    let(:result) { subject.assignment_name event }
    let(:event) { double(:event) }

    context "event has no assignment_id" do
      it "says that no assignment id is present" do
        expect(result).to eq "[assignment id: nil]"
      end
    end

    context "event has an assignment_id" do
      before do
        allow(context).to receive(:assignment_names).and_return({ 40 => "good assignment" })
      end

      it "takes the assignment name from context#assignment_names if one exists" do
        event = double(:event, assignment_id: 40)
        expect(subject.assignment_name event).to eq "good assignment"
      end

      it "just provides the assignment_id if no assignment_name was found" do
        event = double(:event, assignment_id: 9000)
        expect(subject.assignment_name event).to eq "[assignment id: 9000]"
      end
    end
  end

  describe "#username" do
    before do
      allow(context).to receive(:usernames).and_return({ 20 => "herman" })
    end

    it "returns nil if the event has no user_id" do
      event = double(:event)
      expect(subject.username event).to be_nil
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

  describe "#formatted_event_timestamp" do
    it "returns a formated created_at timestamp" do
      parsed_time = Date.parse("Mar 20 2010").to_time
      event = double(:event, created_at: parsed_time)

      expect(subject.formatted_event_timestamp event).to eq "2010-03-20 00:00:00"
    end
  end
end
