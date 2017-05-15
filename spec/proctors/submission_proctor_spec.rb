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

    before(:each) { allow(submission).to receive(:submission_grade).and_return grade }

    it "returns false if the submission is graded but not yet released" do
      allow(submission).to receive(:graded?).and_return true
      allow(grade).to receive(:is_released?).and_return false
      expect(subject.open_for_editing?(assignment, student)).to be_falsey
    end
  end
end
