require "proctor"
require_relative "../../../app/proctors/submission_file_proctor"
require_relative "../../../app/proctors/submission_file_proctor/submission_file_condition_set"

describe Proctors::SubmissionFileConditionSet do
  subject { described_class.new proctor: proctor }
  let(:proctor) { SubmissionFileProctor.new submission_file }

  let(:submission_file) { double(:submission_file, submission: submission) }
  let(:course) { double(:course).as_null_object }
  let(:assignment) { double(:assignment).as_null_object }
  let(:submission) do
    double(:submission, assignment: assignment, course: course).as_null_object
  end
  let(:user) { double(:user) }

  before(:each) do
    # let's presume that we've got a user
    subject.user = user
  end

  it "includes Proctor::Conditions" do
    expect(subject).to respond_to :valid_overrides_present?
    expect(subject).to respond_to :satisfied_by?
  end

  describe "#downloadable_conditions" do
    let(:result) { subject.downloadable_conditions }

    it "adds requirements" do
      # only add the requirements we're testing for here
      allow(assignment).to receive(:has_groups?) { false }
      expect(subject).to receive(:add_requirements)
        .with(:submission_matches_course?, :assignment_present?)
      result
    end

    it "adds some overrides" do
      expect(subject).to receive(:add_overrides).with(:user_is_staff?)
      result
    end

    context "assignment is for individuals" do
      it "requires that the user owns the submission" do
        allow(assignment).to receive(:is_individual?) { true }
        allow(subject).to receive(:add_requirements) { "ignore this for rspec" }
        expect(subject).to receive(:add_requirement).with :user_owns_submission?
        result
      end
    end

    context "assignment is for groups" do
      it "does not require that the user owns the submission" do
        allow(assignment).to receive(:is_individual?) { false }
        expect(subject).not_to receive(:add_requirement)
          .with :user_owns_submission?
        result
      end
    end

    context "assignment has groups" do
      it "adds the group requirements" do
        allow(assignment).to receive(:has_groups?) { true }
        expect(subject).to receive(:add_group_requirements)
        result
      end
    end

    context "assignment does not have groups" do
      it "does not add the group requirements" do
        allow(assignment).to receive(:has_groups?) { false }
        expect(subject).not_to receive(:add_group_requirements)
        result
      end
    end
  end

  describe "#add_group_requirements" do
    it "adds the group requirements" do
      expect(subject).to receive(:add_requirements)
        .with(:user_has_group_for_assignment?, :user_group_owns_submission?)
      subject.add_group_requirements
    end
  end

  describe "#submission_matches_course?" do
    let(:result) { subject.submission_matches_course? }
    before do
      allow(submission).to receive(:course_id) { 5 }
    end

    context "the submission's course_id matches the course's id" do
      it "returns true" do
        allow(course).to receive(:id) { 5 }
        expect(result).to eq true
      end
    end

    context "the submission's course_id does not match the course's id" do
      it "returns false" do
        allow(course).to receive(:id) { 10 }
        expect(result).to eq false
      end
    end
  end

  describe "#user_is_staff?" do
    let(:result) { subject.user_is_staff? }

    context "user is staff for the given course" do
      it "returns true" do
        allow(user).to receive(:is_staff?).with(course) { true }
        expect(result).to eq true
      end
    end

    context "user is not staff for the given course" do
      it "returns false" do
        allow(user).to receive(:is_staff?).with(course) { false }
        expect(result).to eq false
      end
    end
  end

  describe "#assignment_present?" do
    let(:result) { subject.assignment_present? }

    context "assignment is not present" do
      it "returns false" do
        allow(subject).to receive(:assignment) { nil }
        expect(result).to eq false
      end
    end

    context "assignment is present" do
      it "returns true" do
        allow(subject).to receive(:assignment) { assignment }
        expect(result).to eq true
      end
    end
  end

  describe "#user_owns_submission?" do
    let(:result) { subject.user_owns_submission? }
    before do
      allow(submission).to receive(:student_id) { 25 }
    end

    context "the submission's student_id matches the user's id" do
      it "returns true" do
        allow(user).to receive(:id) { 25 }
        expect(result).to eq true
      end
    end

    context "the submission's student_id does not match the user's id" do
      it "returns false" do
        allow(user).to receive(:id) { 44 }
        expect(result).to eq false
      end
    end
  end

  describe "#user_has_group_for_assignment?" do
    let(:result) { subject.user_has_group_for_assignment? }
    let(:group) { double(:group) }

    before do
      allow(user).to receive(:group_for_assignment).with(assignment) { group }
    end

    it "finds the user's group for the assignment" do
      expect(user).to receive(:group_for_assignment).with assignment
      result
    end

    it "sets the group to @group" do
      result
      expect(subject.instance_variable_get :@group).to eq group
    end

    it "returns the user's group for the assignment" do
      expect(result).to eq group
    end
  end

  describe "#user_group_owns_submission?" do
    it "compares the group's id to the submissions group_id" do
      subject.group = double(:group)
      allow(submission).to receive(:group_id) { 5 }
      allow(subject.group).to receive(:id) { 5 }
      expect(subject.user_group_owns_submission?).to eq true
    end
  end
end
