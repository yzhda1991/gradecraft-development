require "analytics"
require "./app/analytics_exports/course_predictor_export"

describe CoursePredictorExport do
  subject { described_class.new export_data }
  let(:export_data) do
    { users: [], assignments: [] }
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


  it "includes Analytics::Export" do
    expect(subject).to respond_to :schema_records
  end
end
