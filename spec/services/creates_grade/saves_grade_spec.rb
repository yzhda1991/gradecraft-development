describe Services::Actions::SavesGrade do
  let(:grade) { build :grade }
  let(:previous_changes_with_raw_points) { { raw_points: 100 } }
  let(:previous_changes_without_raw_points) { { raw_points: nil } }

  it "expects grade passed to service" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "saves the grades" do
    result = described_class.execute grade: grade
    expect(result[:grade]).to_not be_new_record
  end

  it "halts if a record is invalid" do
    grade.student_id = nil
    expect { described_class.execute grade: grade }.to \
      raise_error LightService::FailWithRollbackError
  end
end
