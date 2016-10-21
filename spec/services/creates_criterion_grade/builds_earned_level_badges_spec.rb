require "light-service"
require "active_record_spec_helper"
require "./app/services/creates_criterion_grade/builds_earned_level_badges"

describe Services::Actions::BuildsEarnedLevelBadges do
  let(:world) { World.create.with(:course, :student, :assignment, :rubric, :criterion, :criterion_grade, :grade, :badge) }
  let!(:level_badge) { create :level_badge, level: world.criterion_grade.level, badge: world.badge }

  let(:context) do
    {
      student: world.student,
      assignment: world.assignment,
      criterion_grades: world.criterion_grades,
      grade: world.grade
    }
  end
  it "expects attributes to assign to student" do
    context.delete(:student)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects attributes to assign to assignment" do
    context.delete(:assignment)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects attributes to assign to criterion grades" do
    context.delete(:criterion_grades)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expects attributes to assign to grade" do
    context.delete(:grade)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "promises the built earned level badges" do
    result = described_class.execute context
    expect(result).to have_key :earned_level_badges
  end

  it "assigns level badges to the student for earned levels" do
    result = described_class.execute context
    expect(world.student.earned_badges.count).to eq(1)
  end
end
