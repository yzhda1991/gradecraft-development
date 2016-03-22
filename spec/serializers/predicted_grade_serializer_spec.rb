require "spec_helper"
require "./app/serializers/predicted_grade_serializer"
require "./app/models/null_grade"
require "./app/models/null_student"
require "./lib/grade_proctor"

describe PredictedGradeSerializer do
  let(:course) { double(:course) }
  let(:assignment) { double(:assignment, accepts_submissions?: true, submissions_have_closed?: true )}
  let(:grade) { double(:grade, id: 123, pass_fail_status: :pass, predicted_score: 88, score: 78, final_points: 84, student: user, course: course, assignment: assignment) }
  let(:user) { double(:user, submission_for_assignment: "sumbission") }
  let(:other_user) { double(:other_user) }
  subject { described_class.new assignment, grade, user }

  before { allow_any_instance_of(GradeProctor).to receive(:viewable?).and_return true }

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
      allow_any_instance_of(GradeProctor).to receive(:viewable?).and_return false
      expect(subject.pass_fail_status).to be_nil
    end
  end

  describe "#score" do
    it "returns the grade's score if it's visible" do
      expect(subject.score).to eq grade.score
    end

    it "returns nil if it's not visible" do
      allow_any_instance_of(GradeProctor).to receive(:viewable?).and_return false
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
      expect(described_class.new(assignment, NullGrade.new, NullStudent.new).final_points).to eq(0)
    end
  end

  describe "#final_points" do
    it "returns the grade's final score if it's visible" do
      expect(subject.final_points).to eq grade.final_points
    end

    it "returns nil if it's not visible" do
      allow_any_instance_of(GradeProctor).to receive(:viewable?).and_return false
      expect(subject.final_points).to be_nil
    end

    it "returns 0 with no final score and no sumbission if the assignment submissions have closed" do
      allow(grade).to receive(:final_points).and_return nil
      allow(user).to receive(:submission_for_assignment).and_return nil
      expect(subject.final_points).to eq(0)
    end

    it "doesn't override the final score if present regardless of submission status" do
      allow(user).to receive(:submission_for_assignment).and_return nil
      expect(subject.final_points).to eq(grade.final_points)
    end

    it "always returns 0 for Null Student if the assignment sumbission has closed" do
      expect(described_class.new(assignment, NullGrade.new, NullStudent.new).final_points).to eq(0)
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
      allow_any_instance_of(GradeProctor).to receive(:viewable?).and_return false
      expect(subject.predicted_score).to eq grade.predicted_score
    end
  end

  describe "#attributes" do
    it "returns a hash of grade attributes overriden by Class methods" do
      expect(subject.attributes).to eq({
        id: subject.id,
        predicted_score: subject.predicted_score,
        score: subject.score,
        final_points: subject.final_points
      })
    end
  end
end
