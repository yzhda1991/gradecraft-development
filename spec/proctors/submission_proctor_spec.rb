describe SubmissionProctor do
  subject { described_class.new submission }
  let(:user) { build(:user) }
  let(:course) { build(:course) }
  let(:submission) { build(:submission, course: course) }

  describe "#viewable" do
    before(:each) { allow(user).to receive(:is_student?).with(course).and_return false }

    context "when the current user is not a student in the course" do
      it "returns true if the submission is not a draft" do
        allow(submission).to receive(:unsubmitted?).and_return false
        expect(subject.viewable?(user)).to be true
      end

      it "returns false if the submission is a draft" do
        allow(submission).to receive(:unsubmitted?).and_return true
        expect(subject.viewable?(user)).to be false
      end
    end

    context "when the current user is a student in the course" do
      before(:each) { allow(user).to receive(:is_student?).with(course).and_return true }

      it "returns true" do
        allow(submission).to receive(:belongs_to?).with(user).and_return true
        expect(subject.viewable?(user)).to eq true
      end
    end
  end

  describe "#viewable_submission" do
    it "returns nil if the submission is not viewable" do
      allow(subject).to receive(:viewable?).with(user).and_return(false)
      expect(subject.viewable_submission(user)).to be_nil
    end

    it "returns the submission if the submission is viewable" do
      allow(subject).to receive(:viewable?).with(user).and_return(true)
      expect(subject.viewable_submission(user)).to eq(submission)
    end
  end

  describe "#open_for_editing?" do
    let(:grade) { build(:grade) }
    let(:assignment) { build(:assignment) }
    let!(:student) { create(:course_membership, :student, course: course).user }

    before(:each) do
       allow(submission).to receive(:submission_grade).and_return grade
       allow(user).to receive(:is_student?).with(course).and_return false
       allow(student).to receive(:is_student?).with(course).and_return true
    end

    it "returns true for faculty" do
      expect(subject.open_for_editing?(assignment, user)).to be_truthy
    end

    it "returns false if the sumbission has a grade that is not student visible" do
      allow(submission).to receive(:graded?).and_return true
      allow(grade).to receive(:student_visible?).and_return false
      expect(subject.open_for_editing?(assignment, student)).to be_falsey
    end

    context "graded submissions" do
      let(:grade) {build(:grade, student_visible: true, instructor_modified: true)}

      it "returns true for open resubmission allowed assignments" do
        allow(assignment).to receive(:open?).and_return true
        allow(assignment).to receive(:resubmissions_allowed?).and_return true
        expect(subject.open_for_editing?(assignment, student)).to be_truthy
      end

      it "returns false for closed assignments" do
        allow(assignment).to receive(:open?).and_return false
        allow(assignment).to receive(:resubmissions_allowed?).and_return true
        expect(subject.open_for_editing?(assignment, student)).to be_falsey
      end

      it "returns false for when resubmissions are not allowed" do
        allow(assignment).to receive(:open?).and_return true
        allow(assignment).to receive(:resubmissions_allowed?).and_return false
        expect(subject.open_for_editing?(assignment, student)).to be_falsey
      end
    end
  end
end
