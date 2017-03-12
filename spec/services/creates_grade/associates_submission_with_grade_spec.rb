describe Services::Actions::AssociatesSubmissionWithGrade do
  let(:course) { create :course }
  let(:assignment) { create :assignment, course: course }
  let(:student) { create(:course_membership, :student, course: course).user }
  let(:grade) { create(:grade, assignment: assignment, student: student) }
  let(:group) { create(:group) }
  
  let(:context) {{ assignment: assignment, student: student, grade: grade }}

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
    submission = create(:submission, assignment: assignment, student: student)
    result = described_class.execute context
    expect(result[:grade].submission_id).to eq submission.id
  end

  it "adds nil as submission_id if no submission" do
    result = described_class.execute context
    expect(result[:grade].submission_id).to be_nil
  end

  describe "with a group in the context" do
    it "adds the group submission_id to the grade" do
      context[:group] = group
      submission = create(:group_submission, assignment: assignment, group: group)
      result = described_class.execute context
      expect(result[:grade].submission_id).to eq submission.id
    end

    it "adds nil as submission_id if no submission" do
      context[:group] = group
      result = described_class.execute context
      expect(result[:grade].submission_id).to be_nil
    end
  end
end
