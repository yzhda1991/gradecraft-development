require 'active_record_spec_helper'

describe SubmissionFileProctor do
  subject { described_class.new(submission_file) }

  let(:user) { User.last }
  let(:course) { Course.last }
  let(:submission_file) { SubmissionFile.last }
  let(:submission) { Submission.last }
  let(:assignment) { Assignment.last }

  before do
    create(:user)
    create(:course)
    create(:submission, course: course)
    create(:submission_file, submission: submission)
    create(:assignment)
  end

  it "should have a readable submission_file" do
    expect(subject.submission_file).to eq submission_file
  end

  describe "#initialize" do
    it "accepts a submission file and set it to @submission_file" do
      expect(subject.instance_variable_get(:@submission_file))
        .to eq submission_file
    end
  end

  describe "#downloadable?" do
    let(:result) { subject.downloadable? user: user }

    it "returns an error if :user isn't given" do
      expect { subject.downloadable? }.to raise_error(ArgumentError)
    end

    context "submission course id doesn't match the course id" do
      it "returns false" do
        allow(subject).to receive_message_chain(:course, :id) { 7 }
        allow(submission).to receive(:course_id) { 20_000 }
        expect(result).to eq false
      end
    end

    context "user is staff for the given course" do
      it "returns true" do
      end
    end

    context "assignment is individual" do
      context "the submission's student_id matches the given user's id" do
        it "returns true" do
        end
      end

      context "the submission's student_id doesn't match the given user's id" do
        it "returns false" do
        end
      end
    end

    context "assignment is not individual but has groups" do
      context "user is in the group that owns the submission" do
        it "returns true" do
        end
      end

      context "there is no group for the user for the given assignment" do
      end

      context "there's a group but it isn't the same one on the submission" do
      end
    end

    it "returns false if no other cases are true" do
    end
  end

  describe "#submission" do
    it "gets the submission from the submission_file" do
    end

    it "caches the submission" do
    end

    it "sets the submission to @submission" do
    end
  end

  describe "#assignment" do
    it "gets the assignment from the submission" do
    end

    it "caches the assignment" do
    end

    it "sets the assignment to @assignment" do
    end
  end
end
