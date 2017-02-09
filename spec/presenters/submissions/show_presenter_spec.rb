describe Submissions::ShowPresenter do

  # build a new presenter with some default properties
  subject { described_class.new properties }

  let(:properties) do
    { course: course }
  end

  let(:submission) { double(:submission, student: student, group: group, assignment: assignment, id: 200, submitted_at: Time.now) }
  let(:assignment) { double(:assignment, course: course, threshold_points: 13200, grade_scope: "Group", id: 300).as_null_object }
  let(:course) { double(:course, name: "Some Course").as_null_object }
  let(:student) { double(:user, first_name: "Jimmy", id: 500)}
  let(:group) { double(:group, name: "My group", course: course, id: 400) }
  let(:grade) { double(:grade).as_null_object }

  before(:each) do
    allow(subject).to receive_messages(
      student: student,
      group: group,
      assignment: assignment
    )
  end

  it "inherits from the Submission Presenter" do
    expect(described_class.superclass).to eq Submissions::Presenter
  end

  it "includes SubmissionGradeHistory" do
    expect(subject).to respond_to :submission_grade_filtered_history
  end

  describe "#individual_assignment?" do
    it "returns the output of assignment#is_individual?" do
      allow(subject.assignment).to receive(:is_individual?) { "stuff" }
      expect(subject.individual_assignment?).to eq "stuff"
    end
  end

  describe "#owner" do
    context "the submission is for an individual student assignment" do
      it "returns the student" do
        allow(subject).to receive(:individual_assignment?) { true }
        expect(subject.owner).to eq student
      end
    end

    context "the submission is for a group assignment" do
      it "returns the group" do
        allow(subject).to receive(:individual_assignment?) { false }
        expect(subject.owner).to eq group
      end
    end
  end

  describe "#owner_name" do
    context "the submission is for an individual student assignment" do
      it "returns the student's first name" do
        allow(subject).to receive(:individual_assignment?) { true }
        expect(subject.owner_name).to eq student.first_name
      end
    end

    context "the submission is for a group assignment" do
      it "returns the group name" do
        allow(subject).to receive(:individual_assignment?) { false }
        expect(subject.owner_name).to eq group.name
      end
    end
  end

  describe "#grade" do
    let(:result) { subject.grade }
    let(:grades) { double(:grades).as_null_object }

    before(:each) do
      allow(assignment).to receive(:grades) { grades }
    end

    it "caches the grade" do
      result
      expect(grades).not_to receive(:find_by)
      result
    end

    context "the submission is for an individual student assignment" do
      it "finds the grade by student_id" do
        allow(subject).to receive(:individual_assignment?) { true }
        expect(grades).to receive(:find_by).with(student_id: student.id)
        result
      end
    end

    context "the submission is for a group assignment" do
      it "finds the grade by group_id" do
        allow(subject).to receive(:individual_assignment?) { false }
        expect(grades).to receive(:find_by).with(group_id: group.id)
        result
      end
    end
  end

  describe "#submission" do
    let(:result) { subject.submission }

    context "id exists and Submission.where returns a valid record" do
      before do
        allow(subject).to receive(:id) { 900 }
        allow(Submission).to receive(:where) { [submission] }
      end

      it "finds the submission by id" do
        expect(Submission).to receive(:where).with(id: 900)
        result
      end

      it "caches the submission" do
        result
        expect(Submission).not_to receive(:where).with(id: 900)
        result
      end

      it "sets the submission to an ivar" do
        result
        expect(subject.instance_variable_get(:@submission)).to eq submission
      end
    end

    context "a non-existent id is passed to Submission.where" do
      it "rescues to nil" do
        allow(subject).to receive(:id) { 980_000 }
        expect(result).to eq nil
      end
    end

    context "a nil id is passed to Submission.where" do
      it "rescues to nil" do
        allow(subject).to receive(:id) { nil }
        expect(result).to eq nil
      end
    end
  end

  describe "#student" do
    it "returns the student from the submission" do
      expect(subject.student).to eq submission.student
    end
  end

  describe "#submission_grade_history" do
    before do
      allow(subject).to receive_messages(
        submission: submission,
        grade: grade
      )
    end

    it "returns the submission grade history" do
      expect(subject).to receive(:submission_grade_filtered_history)
        .with(submission, grade, false)
      subject.submission_grade_history
    end
  end

  describe "#submitted_at" do
    it "returns the submitted_at date from the submission" do
      allow(subject).to receive(:submission) { submission }
      expect(subject.submitted_at).to eq submission.submitted_at
    end
  end

  describe "#present_submission_files" do
    # @present_submission_files ||= submission.submission_files.present
    let(:result) { subject.present_submission_files }

    context "presenter has a submission" do
      before do
        allow(subject).to receive(:submission) { submission }
      end

      it "gets the present submission files from the submission" do
        expect(submission).to receive_message_chain(:submission_files, :present)
        result
      end

      it "sets the submission files to an ivar" do
        allow(submission).to receive_message_chain(:submission_files, :present)
          .and_return %w[these are files]
        result
        expect(subject.instance_variable_get :@present_submission_files)
          .to eq %w[these are files]
      end

      it "doesn't query the files again if the ivar was set" do
        subject.instance_variable_set(:@present_submission_files, %w[files])
        expect(submission).not_to receive(:submission_files)
        result
      end
    end

    context "presenter has no submission" do
      before do
        allow(subject).to receive(:submission) { nil }
      end

      it "returns an empty array" do
        expect(result).to eq []
      end
    end
  end

  describe "#missing_submission_files" do
    # @missing_submission_files ||= submission.submission_files.missing
    let(:result) { subject.missing_submission_files }

    context "presenter has a submission" do
      before do
        allow(subject).to receive(:submission) { submission }
      end

      it "gets the missing submission files from the submission" do
        expect(submission).to receive_message_chain(:submission_files, :missing)
        result
      end

      it "sets the submission files to an ivar" do
        allow(submission).to receive_message_chain(:submission_files, :missing)
          .and_return %w[these are files]
        result
        expect(subject.instance_variable_get :@missing_submission_files)
          .to eq %w[these are files]
      end

      it "doesn't query the files again if the ivar was set" do
        subject.instance_variable_set(:@missing_submission_files, %w[files])
        expect(submission).not_to receive(:submission_files)
        result
      end
    end

    context "presenter has no submission" do
      before do
        allow(subject).to receive(:submission) { nil }
      end

      it "returns an empty array" do
        expect(result).to eq []
      end
    end
  end

  describe "#term_for_edit" do
    let(:user) { double(:user) }

    before(:each) { allow(subject).to receive(:submission).and_return submission }

    context "when the current user is a student" do
      before(:each) { allow(user).to receive(:is_staff?).with(course).and_return false }

      it "returns 'Edit Draft' if the submission has a text comment draft" do
        allow(submission).to receive(:text_comment_draft).and_return "Dear professor,"
        expect(subject.term_for_edit(user)).to eq "Edit Draft"
      end

      it "returns 'Edit Submission' if the submission has no text comment draft" do
        allow(submission).to receive(:text_comment_draft).and_return nil
        expect(subject.term_for_edit(user)).to eq "Edit Submission"
      end
    end

    context "when the current user is not a student" do
      before(:each) { allow(user).to receive(:is_staff?).with(course).and_return true }

      it "returns 'Edit Submission'" do
        expect(subject.term_for_edit(user)).to eq "Edit Submission"
      end
    end
  end
end
