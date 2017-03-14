describe Services::Actions::SavesCriterionGrades do
  let(:crt_grade) { build :criterion_grade }

  it "expects criterion grades passed to service" do
    expect { described_class.execute }.to \
      raise_error LightService::ExpectedKeysNotInContextError
  end

  it "saves the criterion grades" do
    result = described_class.execute criterion_grades: [crt_grade]
    expect(result[:criterion_grades].first).to_not be_new_record
  end

  it "halts if a record is invalid" do
    crt_grade.student_id = nil
    expect { described_class.execute criterion_grades: [crt_grade] }.to \
      raise_error LightService::FailWithRollbackError
  end
end
