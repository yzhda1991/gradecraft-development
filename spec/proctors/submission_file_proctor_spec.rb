require "proctor"
require_relative "../../app/proctors/conditions/submission_file_conditions.rb"
require_relative "../../app/proctors/submission_file_proctor.rb"

describe SubmissionFileProctor do
  subject { described_class.new submission_file }
  let(:submission_file) { double(:submission_file) }
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
    # @submission ||= submission_file.submission
    it "caches the submission" do
    end

    it "sets the submission to @submission" do
    end
  end

  describe "#assignment" do
    # @assignment ||= submission.assignment
    it "caches the assignment" do
    end

    it "sets the assignment to @assignment" do
    end
  end
end
