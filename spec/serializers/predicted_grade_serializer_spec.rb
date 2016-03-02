require "spec_helper"
require "./app/serializers/predicted_grade_serializer"

describe PredictedGradeSerializer do
  let(:course) { double(:course) }
  let(:assignment) { double(:assignment, accepts_submissions?: true, submissions_have_closed?: true )}
  let(:grade) { double(:grade, id: 123, pass_fail_status: :pass, predicted_score: 88, score: 78, raw_score: 84, student: user, course: course, assignment: assignment, is_student_visible?: true) }
  let(:user) { double(:user, submission_for_assignment: "sumbission") }
  let(:other_user) { double(:other_user) }
  subject { described_class.new assignment, grade, user }

  describe "#id" do
    it "returns the grade's id" do
      expect(subject.id).to eq grade.id
    end
  end

  describe "#pass_fail_status" do
    it "returns the grade's pass fail status if it's visible" do
      expect(subject.pass_fail_status).to eq grade.pass_fail_status
    end

    it "returns nil if it's not visible" do
      allow(grade).to receive(:is_student_visible?).and_return false
      expect(subject.pass_fail_status).to be_nil
    end
  end

  describe "#score" do
    it "returns the grade's score if it's visible" do
      expect(subject.score).to eq grade.score
    end

    it "returns nil if it's not visible" do
      allow(grade).to receive(:is_student_visible?).and_return false
      expect(subject.score).to be_nil
    end

    it "returns 0 with no score and no sumbission if the assignment submissions have closed" do
      allow(grade).to receive(:score).and_return nil
      allow(user).to receive(:submission_for_assignment).and_return nil
      expect(subject.score).to eq(0)
    end

    it "doesn't override the score is present regardless of submission status" do
      allow(user).to receive(:submission_for_assignment).and_return nil
      expect(subject.score).to eq(grade.score)
    end

    it "always returns 0 for Null Student if the assignment sumbission has closed" do
      expect(described_class.new(assignment, NullGrade.new, NullStudent.new).raw_score).to eq(0)
    end
  end

  describe "#raw_score" do
    it "returns the grade's raw score if it's visible" do
      expect(subject.raw_score).to eq grade.raw_score
    end

    it "returns nil if it's not visible" do
      allow(grade).to receive(:is_student_visible?).and_return false
      expect(subject.raw_score).to be_nil
    end

    it "returns 0 with no raw score and no sumbission if the assignment submissions have closed" do
      allow(grade).to receive(:raw_score).and_return nil
      allow(user).to receive(:submission_for_assignment).and_return nil
      expect(subject.raw_score).to eq(0)
    end

    it "doesn't override the raw score if present regardless of submission status" do
      allow(user).to receive(:submission_for_assignment).and_return nil
      expect(subject.raw_score).to eq(grade.raw_score)
    end

    it "always returns 0 for Null Student if the assignment sumbission has closed" do
      expect(described_class.new(assignment, NullGrade.new, NullStudent.new).raw_score).to eq(0)
    end
  end

  describe "#predicted_score" do
    it "returns the grade's predicted score if the user is a student" do
      allow(grade.student).to \
        receive(:is_student?).with(grade.course).and_return true
      expect(subject.predicted_score).to eq grade.predicted_score
    end

    it "returns 0 predicted_score if user is not same as student for grade" do
      expect((described_class.new assignment, grade, other_user).predicted_score).to eq 0
    end

    it "returns predicted score for student even if it's not visible" do
      allow(grade).to receive(:is_student_visible?).and_return false
      expect(subject.predicted_score).to eq grade.predicted_score
    end
  end

  describe "#attributes" do
    it "returns a hash of grade attributes overriden by Class methods" do
      expect(subject.attributes).to eq({
        id: subject.id,
        predicted_score: subject.predicted_score,
        score: subject.score,
        raw_score: subject.raw_score
      })
    end
  end
end
