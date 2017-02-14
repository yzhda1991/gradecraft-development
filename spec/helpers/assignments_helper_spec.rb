require "spec_helper"

describe AssignmentsHelper do
  class Helper
    include AssignmentsHelper
  end

  subject(:helper) { Helper.new }

  describe "#mark_assignment_reviewed!" do
    let(:assignment) { double(:assignment, course: course) }
    let(:course) { double(:course) }
    let(:grade) { double(:grade, new_record?: false) }
    let(:user) { double(:user) }

    it "it marks the grade feedback as reviewed for the current user" do
      allow(user).to receive(:is_student?).with(course).and_return true
      allow(user).to receive(:grade_released_for_assignment?).with(assignment)
        .and_return true
      allow(user).to receive(:grade_for_assignment).with(assignment).and_return grade
      expect(grade).to receive(:feedback_reviewed!)
      helper.mark_assignment_reviewed! assignment, user
    end
  end
end
