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
end
