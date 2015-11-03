require "active_record_spec_helper"

describe User do
  let(:course) { create(:course) }
  let(:student) { create(:user) }
  let(:course_membership) { create(:student_course_membership, user: student, course: course) }
  let(:assignment) { create(:assignment, course: course) }
  let(:grade) { create(:grade, assignment: assignment, course: course, student: student) }


  describe "#cache_course_score", focus: true do
    subject { student.cache_course_score(course.id) }

    context "course membership is present" do
      let(:stub_course_membership) { allow(student).to receive(:fetch_course_membership) { course_membership } }

      it "fetches the proper course membership" do
        expect(student).to receive(:fetch_course_membership) { course_membership }
        subject
      end

      it "checks whether the course_membership is nil" do
        stub_course_membership
        expect(course_membership).to receive(:nil?)
        subject
      end

      it "recalculates and updates the student score" do
        stub_course_membership
        expect(course_membership).to receive(:recalculate_and_update_student_score)
        subject
      end

      it "returns the the recalculated student score" do
        stub_course_membership
        allow(course_membership).to receive(:recalculate_and_update_student_score) { 58000 }
        expect(subject).to eq(58000)
      end
    end

    context "course membership is nil" do
      let(:stub_course_membership) { allow(student).to receive(:fetch_course_membership) { nil } }

      it "doesn't recalculate the student score" do
        stub_course_membership
        expect(course_membership).not_to receive(:recalculate_and_update_student_score)
        subject
      end

      it "returns nil" do
        stub_course_membership
        expect(subject).to eq(nil)
      end
    end
  end

  describe "#improved_cache_course_score", focus: true do
    context "course membership is present" do
      it "recalculates and updates the student score" do
      end
    end

    context "course membership is nil" do
      it "doesn't recalculate the student score" do
      end
    end
  end

  describe "#fetch_course_membership", focus: true do
  end
end
