require "spec_helper"
require "./app/presenters/submission_presenter"

describe SubmissionPresenter do
  let(:assignment_id) { 123 }
  let(:course) { double(:course) }
  subject { described_class.new assignment_id: assignment_id, course: course }

  describe "#assignment" do
    it "returns the assignment from the id passed in as a property" do
      assignment = double(:assignment)
      assignments = double(:active_record_relation)
      allow(assignments).to receive(:find).with(123).and_return assignment
      allow(course).to receive(:assignments).and_return assignments
      expect(subject.assignment).to eq assignment
    end
  end

  describe "#course" do
    it "is the course that is passed in as a property" do
      expect(subject.course).to eq course
    end
  end
end
