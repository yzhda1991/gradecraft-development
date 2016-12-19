require "light-service"
require "active_record_spec_helper"
require "./app/services/creates_grade/associates_submission_with_grade"

describe Services::Actions::AssociatesSubmissionWithGrade do

  let(:world) { World.create.with(:course, :student, :assignment, :grade, :group) }
  let(:context) {{ assignment: world.assignment, student: world.student, grade: world.grade }}

  it "expect student to be added to the context" do
    context.delete(:student)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expect assignment to be added to the context" do
    context.delete(:assignment)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "expect grade to be added to the context" do
    context.delete(:grade)
    expect { described_class.execute context }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "adds a submission_id to the grade" do
    submission = create(:submission, assignment: world.assignment, student: world.student)
    result = described_class.execute context
    expect(result[:grade].submission_id).to eq submission.id
  end

  it "adds nil as submission_id if no submission" do
    result = described_class.execute context
    expect(result[:grade].submission_id).to be_nil
  end

  describe "with a group in the context" do
    it "adds the group submission_id to the grade" do
      context[:group] = world.group
      submission = create(:group_submission, assignment: world.assignment, group: world.group)
      result = described_class.execute context
      expect(result[:grade].submission_id).to eq submission.id
    end

    it "adds nil as submission_id if no submission" do
      context[:group] = world.group
      result = described_class.execute context
      expect(result[:grade].submission_id).to be_nil
    end
  end
end
