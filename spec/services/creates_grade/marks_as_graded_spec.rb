describe Services::Actions::MarksAsGraded do
  let(:grade) { create :grade }

  it "expect grade to be added to the context" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "adds attributes to the grade" do
    result = described_class.execute grade: grade
    expect(result[:grade].graded_at).to be_within(1.second).of(Time.now)
    expect(result[:grade].instructor_modified).to be_truthy
  end
end
