describe Services::CreatesGroupGradesUsingRubric do
  let(:professor) { build_stubbed :user }
  let(:assignment) { create :assignment }
  let(:group) { create :group }
  let(:group_params) {{ "group_id" => group.id }}
  let(:params) { RubricGradePUT.new(assignment).params.merge group_params }

  describe ".create" do
    it "verifies that the group exists" do
      expect(Services::Actions::VerifiesGroup).to receive(:execute).and_call_original
      described_class.create params, professor.id
    end

    it "iterates through the students in a group" do
      expect(Services::Actions::IteratesCreatesGradeUsingRubric).to receive(:execute).and_call_original
      described_class.create params, professor.id
    end
  end
end
