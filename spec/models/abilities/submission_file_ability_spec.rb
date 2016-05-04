require "active_record_spec_helper"
require "cancan/matchers"

describe Ability do
  subject { described_class.new(student, course) }

  let(:course) { student_course_membership.course }
  let(:student_course_membership) { create :student_course_membership }
  let(:student) { student_course_membership.user }

  describe "for SubmissionFiles" do
    before(:each) do
      allow_any_instance_of(SubmissionFileProctor).to receive(:downloadable?)
        .with(user: student, course: course) { downloadable? }
    end

    context "proctor says submission file is downloadable" do
      let(:downloadable?) { true }

      it "can download the submission file" do
        expect(subject).to be_able_to(:download, SubmissionFile.new)
      end
    end

    context "proctor says submission file is not downloadable" do
      let(:downloadable?) { false }

      it "can't download the submission file" do
        expect(subject).to_not be_able_to(:download, SubmissionFile.new)
      end
    end
  end
end
