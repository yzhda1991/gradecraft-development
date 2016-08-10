require "active_record_spec_helper"

describe User do
  let(:course) { create(:course) }
  let(:student) { create(:user) }
  let(:course_membership) { create(:student_course_membership, user: student, course: course) }
  let(:assignment) { create(:assignment, course: course) }
  let(:grade) { create(:grade, assignment: assignment, course: course, student: student) }

  describe "#cache_course_score_and_level" do
    subject { student.cache_course_score_and_level(course.id) }

    it "fetches the proper course membership" do
      expect(student).to receive(:fetch_course_membership) { course_membership }
      subject
    end

    context "course membership is present" do
      before(:each) { allow(student).to receive(:fetch_course_membership) { course_membership } }

      it "checks whether the course_membership is nil" do
        expect(course_membership).to receive(:nil?)
        subject
      end

      it "recalculates and updates the student score" do
        expect(course_membership).to receive(:recalculate_and_update_student_score)
        subject
      end

      it "returns the the recalculated student score" do
        allow(course_membership).to receive(:recalculate_and_update_student_score) { 58000 }
        expect(subject).to eq(true)
      end
    end

    context "course membership is nil" do
      before(:each) { allow(student).to receive(:fetch_course_membership) { nil } }

      it "doesn't recalculate the student score" do
        expect(course_membership).not_to receive(:recalculate_and_update_student_score)
        subject
      end

      it "returns nil" do
        expect(subject).to eq(nil)
      end
    end
  end

  describe "#fetch_course_membership(course_id)" do
    it "returns the course membership with matching course_id" do
      course_membership # cache the course membership so we can find it later
      expect(student.fetch_course_membership(course.id)).to eq(course_membership)
    end
  end
end
