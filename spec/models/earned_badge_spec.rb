require "active_record_spec_helper"

describe EarnedBadge do

  subject { build(:earned_badge) }

  context "validations" do
    it "is valid with a badge, a course, and a student" do
      expect(subject).to be_valid
    end
  end

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

  describe "#points" do
    let(:student) { create :user }

    it "returns badge full points for points" do
      badge = create(:badge, full_points: 123)
      earned_badge = EarnedBadge.create(badge_id: badge.id, student_id: student.id)
      expect(earned_badge.points).to eq(123)
    end
  end

  describe "#earnable" do
    it "allows a student to earn a badge if they haven't earned it yet" do
      badge = create(:badge)
      student = create(:user)
      earned_badge = create(:earned_badge, badge: badge, student: student)
      expect(earned_badge).to be_valid
    end

    it "allows a student to earn a badge multiple times if multiple_allowed" do
      badge = create(:badge, can_earn_multiple_times: true)
      student = create(:user)
      earned_badge = create(:earned_badge, badge: badge, student: student, student_visible: true)
      earned_badge_2 = create(:earned_badge, badge: badge, student: student, student_visible: true)
      earned_badge_3 = create(:earned_badge, badge: badge, student: student, student_visible: true)
      expect(badge.earned_badge_count_for_student(student)).to eq(3)
    end

    it "prevents a student from earning a badge if multiple_times not allowed" do
      badge = create(:badge, can_earn_multiple_times: false)
      student = create(:user)
      EarnedBadge.create(badge_id: badge.id, student_id: student.id, student_visible: true)
      EarnedBadge.create(badge_id: badge.id, student_id: student.id, student_visible: true)
      expect(badge.earned_badge_count_for_student(student)).to eq(1)
    end

    it "allows a single earned badge to be resaved" do
      badge = create(:badge, can_earn_multiple_times: false)
      student = create(:user)
      eb = EarnedBadge.create(badge_id: badge.id, student_id: student.id, student_visible: true)
      expect(eb.save).to be_truthy
    end
  end

  describe "#add_associations" do
    it "pulls the course id off of badge" do
      badge = create(:badge, full_points: 123)
      earned_badge = EarnedBadge.create(badge_id: badge.id)
      expect(earned_badge.course_id).to eq(badge.course_id)
    end
  end

  describe "#student_visible" do
    it "is not visible if the grade is not visible" do
      grade = create(:grade, status: "In Progress")
      subject = create(:earned_badge, grade: grade)
      expect(subject).to_not be_student_visible
    end

    it "is visible if the grade is visible" do
      grade = create(:grade, status: "Released")
      subject = create(:earned_badge, grade: grade)
      expect(subject).to be_student_visible
    end

    it "is always set to visible if no grade associated" do
      subject = create(:earned_badge, student_visible: false)
      expect(subject).to be_student_visible
    end
  end
end
