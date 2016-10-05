require "light-service"
require "active_record_spec_helper"
require "./app/services/creates_earned_badge/creates_earned_badge"

describe Services::Actions::CreatesEarnedBadge do
  let(:world) { World.create.with(:course, :assignment, :professor, :student, :badge, :grade) }
  let(:result) { described_class.execute attributes: attributes }

  context "as a professor" do

    let(:attributes) do
      {
        student_id: world.student.id,
        badge_id: world.badge.id,
        assignment_id: world.assignment.id,
        grade_id: world.grade.id,
        course_id: world.course.id,
        awarded_by_id: world.professor.id,
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
      expect(result.earned_badge.awarded_by).to eq(world.professor)
    end

    it "halts if the earned badge is invalid" do
      attributes[:student_id] = nil
      expect { described_class.execute attributes: attributes }.to \
        raise_error LightService::FailWithRollbackError
    end
  end

  context "as a student", focus: true do

    describe "awarding a student-awardable badge to another student" do
      let(:result) do
        badge = world.badge
        badge.student_awardable = true
        badge.save

        other_student = create(:user)
        other_student.courses << world.course

        described_class.execute attributes: {
          student_id: other_student.id,
          badge_id: badge.id,
          assignment_id: world.assignment.id,
          grade_id: world.grade.id,
          course_id: world.course.id,
          awarded_by_id: world.student.id,
          student_visible: true,
          feedback: "You are so awesome!"
        }
      end

      it "promises the created earned badge", focus: true do
        expect(result).to have_key :earned_badge
        expect(result.earned_badge).to be_persisted
      end

      it "creates the earned badge with the correct awarded_by" do
        expect(result.earned_badge.awarded_by).to eq(world.student)
      end
    end
  end
end
