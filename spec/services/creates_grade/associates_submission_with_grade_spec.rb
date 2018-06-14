describe Services::Actions::AssociatesSubmissionWithGrade do
  let(:course) { build :course }
  let(:student) { build(:course_membership, :student, course: course).user }
  let(:grade) { build :grade, assignment: assignment, student: student }

  let(:context) do
    {
      assignment: assignment,
      student: student,
      grade: grade
    }
  end

  context "when the assignment is individually graded" do
    let(:assignment) { build_stubbed :assignment, course: course }

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

    it "adds a submission_id to the grade if one is found" do
      submission = build :submission, assignment: assignment, student: student
      result = described_class.execute context
      expect(result[:grade].submission_id).to eq submission.id
    end

    it "does not reset the submission_id if no submission is found" do
      grade.submission_id = 1234
      result = described_class.execute context
      expect(result[:grade].submission_id).to eq 1234
    end
  end

  context "when the assignment is group graded" do
    let(:group) { create :group, course: course }
    let(:assignment) { build_stubbed :group_assignment, course: course }
    let!(:assignment_group) { create :assignment_group, assignment: assignment, group: group }
    let!(:group_membership) { create :group_membership, student: student, group: group }

    let(:group_context) { context.merge group: group }

    it "adds the group submission_id to the grade if one is found" do
      submission = build :group_submission, assignment: assignment, group: group
      result = described_class.execute group_context
      expect(result[:grade].submission_id).to eq submission.id
    end

    it "adds nil as submission_id if no submission if no submission is found" do
      result = described_class.execute group_context
      expect(result[:grade].submission_id).to be_nil
    end
  end
end
