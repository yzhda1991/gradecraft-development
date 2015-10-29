require "active_record_spec_helper"

describe EarnedBadge do
  describe ".for_course" do
    it "returns all earned badge for a specific course" do
      course = create(:course)
      course_earned_badge = create(:earned_badge, course: course)
      another_earned_badge = create(:earned_badge)
      results = EarnedBadge.for_course(course)
      expect(results).to eq [course_earned_badge]
    end
  end

  describe ".for_student" do
    it "returns all earned badges for a specific student" do
      student = create(:user)
      student_earned_badge = create(:earned_badge, student: student)
      another_earned_badge = create(:earned_badge)
      results = EarnedBadge.for_student(student)
      expect(results).to eq [student_earned_badge]
    end
  end
end
