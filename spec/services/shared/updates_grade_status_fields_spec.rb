describe Services::Actions::UpdatesGradeStatusFields do
  let(:grade) { create :grade }

  it "expect grade to be added to the context" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  context "when release is not required" do
    it "updates the fields on 'In Progress' grades" do
      grade.update(status: "In Progress")
      result = described_class.execute grade: grade
      expect(result[:grade].complete).to be_falsey
      expect(result[:grade].student_visible).to be_falsey
    end

    it "updates the fields on 'Graded' grades" do
      grade.update(status: "Graded")
      result = described_class.execute grade: grade
      expect(result[:grade].complete).to be_truthy
      expect(result[:grade].student_visible).to be_truthy
    end
  end

  context "when release is necessary" do
    before do
      grade.assignment.update(release_necessary: true)
    end

    it "updates the fields on 'In Progress' grades" do
      grade.update(status: "In Progress")
      result = described_class.execute grade: grade
      expect(result[:grade].complete).to be_falsey
      expect(result[:grade].student_visible).to be_falsey
    end

    it "updates the fields on 'Graded' grades" do
      grade.update(status: "Graded")
      result = described_class.execute grade: grade
      expect(result[:grade].complete).to be_truthy
      expect(result[:grade].student_visible).to be_falsey
    end

    it "updates the fields on 'Released' grades" do
      grade.update(status: "Released")
      result = described_class.execute grade: grade
      expect(result[:grade].complete).to be_truthy
      expect(result[:grade].student_visible).to be_truthy
    end
  end
end
