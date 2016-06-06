require "analytics"
require "./app/analytics_exports/course_predictor_export"

describe CoursePredictorExport do
  subject { described_class.new users: users, assignments: assignments }

  let(:users) do
    [double(:user, id: 1, username: "anna"),
     double(:user, id: 2, username: "barry")]
  end

  it "includes Analytics::Export::Model" do
    expect(subject).to respond_to(:schema_records)
  end

  let(:assignments) do
    [double(:assignment, id: 3, name: "writing"),
     double(:assignment, id: 4, name: "rithmatic")]
  end

  describe "#assignment_name" do
    let(:result) { subject.assignment_name event, 20 }
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

  it "includes Analytics::Export" do
    expect(subject).to respond_to :schema_records
  end

  describe "accessible attributes" do
    it "has accessible usernames" do
      subject.usernames = %w[user names]
      expect(subject.usernames).to eq %w[user names]
    end

    it "has accessible assignment names" do
      subject.assignment_names = %w[user names]
      expect(subject.assignment_names).to eq %w[user names]
    end
  end

  describe "readable attributes" do
    it "has a readable loaded_data attribute" do
      subject.instance_variable_set(:@loaded_data, "data!!")
      expect(subject.loaded_data).to eq "data!!"
    end
  end

  describe "rows_by definition" do
    it "filters the rows by events" do
      expect(described_class.rows).to eq :events
    end
  end

  describe "export schema" do
    it "uses a schema for exporting the records" do
      sanitized_schema = described_class.schema.tap {|h| h.delete :date_time }
      expect(sanitized_schema).to eq({
        username: :username,
        role: :user_role,
        student_profile: :student_profile,
        assignment: :assignment_name,
        prediction: :score,
        possible: :possible
      })
    end
  end

  describe "#initialize" do
    it "sets the loaded data" do
      expect(subject.loaded_data)
        .to eq({ users: users, assignments: assignments })
    end

    it "gets and caches the usernames" do
      expect_any_instance_of(described_class)
        .to receive(:get_and_cache_usernames)
      subject
    end

    it "gets and caches assignment names" do
      expect_any_instance_of(described_class)
        .to receive(:get_and_cache_assignment_names)
      subject
    end
  end

  describe "#schema_records_for_role" do
    let(:result) { subject.schema_records_for_role "some role" }
    let(:records) do
      [double(:event, user_role: "some role"),
       double(:event, user_role: "another role")]
    end

    it "builds the schema records for records with the given role" do
      allow(subject).to receive(:records) { records }
      expect(subject).to receive(:schema_records).with [records.first]
      result
    end
  end

  describe "#get_and_cache_usernames" do
    let(:result) { subject.get_and_cache_usernames }

    it "builds a hash of format { user_id: username }" do
      expect(result).to eq({ 1 => "anna", 2 => "barry" })
    end

    it "sets the result to @usernames" do
      result
      expect(subject.instance_variable_get(:@usernames))
        .to eq({ 1 => "anna", 2 => "barry" })
    end

    it "caches the value" do
      result
      expect(subject.loaded_data[:users]).not_to receive(:inject)
      result
    end
  end

  describe "#get_and_cache_usernames" do
    let(:result) { subject.get_and_cache_assignment_names }

    it "builds a hash of format { assignment_id: assignment name }" do
      expect(result).to eq({ 3 => "writing", 4 => "rithmatic" })
    end

    it "sets the result to @usernames" do
      result
      expect(subject.instance_variable_get(:@assignment_names))
        .to eq({ 3 => "writing", 4 => "rithmatic" })
    end

    it "caches the value" do
      result
      expect(subject.loaded_data[:users]).not_to receive(:inject)
      result
    end
  end

  describe "#filter" do
    let(:events) do
      [double(:event, event_type: "predictor"),
       double(:event, event_type: "something else")]
    end

    it "selects the events that have a predictor event type" do
      expect(subject.filter events).to eq [events.first]
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
  end
end
