require "analytics"
require "./app/analytics_exports/course_predictor_export"

describe CoursePredictorExport do
  subject { described_class.new context: context }
  let(:context) { double(:context).as_null_object }

  it "includes Analytics::Export::Model" do
    expect(subject.class).to respond_to(:column_mapping)
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
      before(:each) do
        allow(event).to receive(:assignment_id) { 50 }
        subject.instance_variable_set(:@assignment_names, assignment_names)
      end

      context "the assignment_id exists in @assignment_names" do
        let(:assignment_names) do
          { 50 => "this assignment" }
        end

        it "returns the name for the assignment" do
          expect(result).to eq "this assignment"
        end
      end

      context "the assignment_id doesn't exist in @assignment_names" do
        let(:assignment_names) do
          { 33 => "some other assignment" }
        end

        it "returns a placeholder for the assignment name with the id" do
          expect(result).to eq "[assignment id: 50]"
        end
      end
    end
  end

  describe "#username" do
    let(:event) { double :event, user_id: 5 }
    before { allow(subject).to receive(:usernames) { usernames } }

    context "usernames hash has a key matching the event's user_id" do
      let(:usernames) { { 5 => "josiah" } }

      it "selects the events that have a predictor event type" do
        expect(subject.username event).to eq "josiah"
      end
    end

    context "usernames hash has no key matching the event's user_id" do
      let(:usernames) { { 10 => "annabelle" } }

      it "selects the events that have a predictor event type" do
        expect(subject.username event).to eq "[user id: 5]"
      end
    end

    context "event has a nil user_id" do
      it "returns nil" do
        event = double :event, user_id: nil
        expect(subject.username event).to be_nil
      end
    end

    context "event has no user_id attribute" do
      it "returns nil" do
        event = double :event, no_user_id_here: "seriously"
        expect(subject.username event).to be_nil
      end
    end
  end
end
