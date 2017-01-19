require "light-service"
require "active_record_spec_helper"
require "./app/services/creates_earned_badge/creates_earned_badge"

describe Services::Actions::CreatesEarnedBadge do
  let(:course) { create :course }
  let(:badge) { create :badge }
  let(:student) { create(:course_membership, :student, course: course).user}
  let(:grade) { create :grade, course: course, student: student }
  let(:professor) { create(:course_membership, :professor, course: course).user}
  let(:result) { described_class.execute attributes: attributes }

  context "as a professor" do

    let(:attributes) do
      {
        student_id: student.id,
        badge_id: badge.id,
        grade_id: grade.id,
        course_id: course.id,
        awarded_by_id: professor.id,
        student_visible: true,
        feedback: "You are so awesome!"
      }
    end

    it "expects attributes to create the earned badge" do
      expect { described_class.execute }.to \
        raise_error LightService::ExpectedKeysNotInContextError
    end

    it "promises the created earned badge" do
      expect(result).to have_key :earned_badge
      expect(result.earned_badge).to be_persisted
    end

    it "creates the earned badge with the correct awarded_by" do
      expect(result.earned_badge.awarded_by).to eq(professor)
    end

    it "halts if the earned badge is invalid" do
      attributes[:student_id] = nil
      expect { described_class.execute attributes: attributes }.to \
        raise_error LightService::FailWithRollbackError
    end
  end

  context "as a student" do

    describe "awarding a student-awardable badge to another student" do
      let(:attributes) do
        badge.student_awardable = true
        badge.save

        other_student = create(:user, courses: [course], role: :student)

        {
          student_id: other_student.id,
          badge_id: badge.id,
          course_id: course.id,
          awarded_by_id: student.id,
          student_visible: true,
          feedback: "You are so awesome!"
        }
      end

      it "promises the created earned badge" do
        expect(result).to have_key :earned_badge
        expect(result.earned_badge).to be_persisted
      end

      it "creates the earned badge with the correct awarded_by" do
        expect(result.earned_badge.awarded_by).to eq(student)
      end
    end

    describe "awarding a non-student-awardable badge to another student" do
      let(:attributes) do
        other_student = create(:user, courses: [course], role: :student)

        {
          student_id: other_student.id,
          badge_id: badge.id,
          course_id: course.id,
          awarded_by_id: student.id,
          student_visible: true,
          feedback: "You are so awesome!"
        }
      end

      it "does not create the earned badge" do
        expect { described_class.execute attributes: attributes }.to \
          raise_error LightService::FailWithRollbackError
      end
    end
  end
end
