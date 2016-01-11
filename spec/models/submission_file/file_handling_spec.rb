require "rails_spec_helper"

describe SubmissionFile do
  let(:course) { build(:course) }
  let(:assignment) { build(:assignment) }
  let(:student) { build(:user) }
  let(:submission) { build(:submission, course: course, assignment: assignment, student: student) }
  let(:submission_file) { submission.submission_files.last }

  describe "#confirmed?" do
    subject { submission_file.confirmed? }

    context "has a last_confirmed_at time and the file isn't missing" do
      let(:submission_file) { build(:submission_file, last_confirmed_at: Time.now, file_missing: false) }
      it "is confirmed" do
        expect(subject).to be_truthy
      end
    end

    context "has no last_confirmed_at time" do
      let(:submission_file) { build(:submission_file, last_confirmed_at: nil, file_missing: false) }
      it "is not confirmed" do
        expect(subject).to be_falsey
      end
    end

    context "the file is missing" do
      let(:submission_file) { build(:submission_file, last_confirmed_at: Time.now, file_missing: true) }
      it "is not confirmed" do
        expect(subject).to be_falsey
      end
    end
  end
  
end
