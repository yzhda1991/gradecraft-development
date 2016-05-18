require "proctor"
require_relative "../../app/proctors/conditions/submission_file_conditions.rb"
require_relative "../../app/proctors/submission_file_proctor.rb"

describe SubmissionFileProctor do
  subject { described_class.new submission_file }
  let(:submission_file) { double(:submission_file, submission: submission) }
  let(:course) { double(:course).as_null_object }
  let(:assignment) { double(:assignment).as_null_object }
  let(:submission) do
    double :submission, assignment: assignment, course: course
  end

  let(:proctor_conditions) do
    Proctors::SubmissionFileConditions.new proctor: subject
  end

  describe "readable attributes" do
    it "has a readable submission file" do
      expect(subject.submission_file).to eq submission_file
    end
  end

  describe "#initialize" do
    it "sets the given submission_file to @submission_file" do
      expect(subject.instance_variable_get :@submission_file)
        .to eq submission_file
    end
  end

  describe "#downloadable?" do
    let(:result) { subject.downloadable? user: user }
    let(:user) { double(:user) }
    let(:downloadable_conditions) { double(:downloadable).as_null_object }

    before do
      allow(subject).to receive(:proctor_conditions) { proctor_conditions }
      allow(proctor_conditions).to receive(:for) { downloadable_conditions }
    end

    it "gets the proctor conditions for downloadable" do
      expect(proctor_conditions).to receive(:for).with(:downloadable)
      result
    end

    it "checks whether the downloadable conditions are satisfied by the user" do
      expect(downloadable_conditions).to receive(:satisfied_by?).with user
      result
    end
  end

  describe "#proctor_conditions" do
    # @proctor_conditions ||= Proctors::SubmissionFileConditions.new(proctor: self)
    it "caches the proctor_conditions" do
    end

    it "sets the proctor conditions to @proctor_conditions" do
    end
  end

  describe "#course" do
    # @course ||= submission.course
    it "caches the course" do
    end

    it "sets the course to @course" do
    end
  end

  describe "#submission" do
    let(:result) { subject.submission }

    before do
      allow(submission_file).to receive(:submission) { submission }
    end

    it "gets the submission from the submission_file" do
      expect(result).to eq submission
    end

    it "caches the submission" do
      result
      expect(submission_file).not_to receive(:submission)
      result
    end

    it "sets the submission to @submission" do
      result
      expect(subject.instance_variable_get(:@submission)).to eq submission
    end
  end

  describe "#assignment" do
    let(:result) { subject.assignment }

    before do
      allow(submission).to receive(:assignment) { assignment }
    end

    it "gets the assignment from the submission" do
      expect(result).to eq assignment
    end

    it "caches the assignment" do
      result
      expect(submission).not_to receive(:assignment)
      result
    end

    it "sets the assignment to @assignment" do
      result
      expect(subject.instance_variable_get(:@assignment)).to eq assignment
    end
  end
end
