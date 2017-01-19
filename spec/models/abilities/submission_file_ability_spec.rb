require "active_record_spec_helper"
require "cancan/matchers"
require_relative "../../support/test_classes/models/abilities/submission_file_ability_test"

describe SubmissionFileAbility do
  describe SubmissionFileAbilityTest do
    subject { described_class.new(student) }

    let(:student_course_membership) { create :course_membership, :student }
    let(:student) { student_course_membership.user }

    before(:each) do
      allow_any_instance_of(SubmissionFileProctor).to receive(:downloadable_by?)
        .with(student) { downloadable? }
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
