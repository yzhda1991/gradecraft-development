require 'active_record_spec_helper'

describe SubmissionFileProctor do
  subject { described_class.new(submission_file) }

  let(:user) { create(:user) }
  let(:course) { create(:course) }
  let(:submission) { create(:submission, course: course) }
  let(:submission_file) { create(:submission_file, submission: submission) }
  let(:assignment) { create(:assignment) }
  let(:group) { create(:group) }

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
        allow(user).to receive(:is_staff?).with(course) { true }
        expect(result).to eq true
      end
    end

    context "no assignment exists" do
      it "returns false" do
        allow(subject).to receive(:assignment) { nil }
        expect(result).to eq false
      end
    end

    context "assignment is individual" do
      before do
        allow(assignment).to receive(:is_individual?) { true }
      end

      context "the submission's student_id matches the given user's id" do
        it "returns true" do
          allow(submission).to receive(:student_id) { user.id }
          expect(result).to eq true
        end
      end

      context "the submission's student_id doesn't match the given user's id" do
        it "returns false" do
          allow(submission).to receive(:student_id) { 900_000 }
          expect(result).to eq false
        end
      end
    end

    context "assignment is not individual but has groups" do
      before do
        allow(subject).to receive(:assignment) { assignment }
        allow(assignment).to receive_messages(
          is_individual?: false,
          has_groups?: true
        )
      end

      context "there is no group for the user for the given assignment" do
        it "returns false" do
          allow(user).to receive(:group_for_assignment).with(assignment) { nil }
          expect(result).to eq false
        end
      end

      context "user has a group for the assignment" do
        before(:each) do
          allow(user).to receive(:group_for_assignment).with(assignment) { group }
        end

        context "user is in the group that owns the submission" do
          it "returns true" do
            allow(submission).to receive(:group_id) { group.id }
            expect(result).to eq true
          end
        end

        context "there's a group but it isn't the same one on the submission" do
          it "returns false" do
            allow(submission).to receive(:group_id) { 885_000 }
            expect(result).to eq false
          end
        end
      end
    end

    it "returns false if no other cases are true" do
      allow(subject).to receive(:assignment) { assignment }
      allow(assignment).to receive_messages(
        is_individual?: false,
        has_groups?: false
      )
      expect(result).to eq false
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
